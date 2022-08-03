"""Module to handle the routes.
Group 10: Xu Feng, Xuefan Han, Hangyu Li, Xuchang Liu, Sherry Xu
Professor: Nick Machairas
May 01, 2022
"""
import elasticsearch
from elasticsearch_dsl import connections, Search
from flask import render_template
from idna import InvalidCodepoint
from pyspark import SparkContext
from app import app
from app.forms import SearchForm, SparkForm
from pyspark.conf import SparkConf
from pyspark.sql import SQLContext
from pyspark.sql.functions import col
from pyspark.ml.feature import RegexTokenizer, StopWordsRemover, Word2Vec
from pyspark.sql import SQLContext
import numpy as np
import pandas as pd

# elasticsearch
client = connections.create_connection(hosts=["localhost"],
                     port=9200)

@app.route('/', methods=['GET', 'POST'])
def home():
    """Render the home page."""
    form = SearchForm()
    search_results = None
    if form.validate_on_submit():
        Descriptor = form.Descriptor.data
        s = Search(using=client, index="services").query("match", Descriptor=Descriptor) 
        search_results = s.execute()
        
      
    return render_template(
        "home.html", form=form, 
        search_results=search_results)

# spark
@app.route('/spark', methods=['GET', 'POST'])
def test_spark():
    """"new template"""
    form = SparkForm()
    search_results= pd.DataFrame()
    # sc.stop()
    # sc = SparkContext(conf = config) 
    #config = sc.getConf()
    #config.set('spark.cores.max','8')
    #config.set('spark.executor.memory', '16G')
    #config.set('spark.driver.maxResultSize', '12g')
    #config.set('spark.kryoserializer.buffer.max', '512m')
    #config.set("spark.driver.cores", "8")
    #sc = SparkContext(conf=config)
    if form.validate_on_submit():
        sc = SparkContext("local")
        sqlContext = SQLContext(sc) #pay attention
        cb_file="/Users/apple/Library/Containers/com.tencent.xinWeChat/Data/Library/Application Support/com.tencent.xinWeChat/2.0b4.0.9/e130d25fbcf581ae9b1db5c0a5d2658b/Message/MessageTemp/8cd74c3da9e314b72021191488de2f64/File/apan_flask_apps-postgres 2/apan_flask_apps-postgres/app/311_Service_Requests.csv"
        cb_sdf = sqlContext.read.option("header", "true").option("delimiter", ",").option("inferSchema", "true").csv(cb_file)
        Query = form.Query.data
        regexTokFilter = RegexTokenizer(gaps = False, pattern = '\w+', inputCol = 'Complaint_Type', outputCol = 'tokens')
        stopwordFilter = StopWordsRemover(inputCol = 'tokens', outputCol = 'tokens_sw_removed')
        cb_sdf_tok = regexTokFilter.transform(cb_sdf)
        cb_sdf_swr = stopwordFilter.transform(cb_sdf_tok)
        cb_sdf_subset = cb_sdf_swr.limit(30000)
        word2vec = Word2Vec(vectorSize = 50, minCount = 5, inputCol = 'tokens_sw_removed', outputCol = 'wordvectors')
        model = word2vec.fit(cb_sdf_subset)
        wordvectors = model.transform(cb_sdf_subset)
        cb_sdf_w2v = wordvectors.select('Unique_Key','Agency_Name','Complaint_Type','wordvectors').rdd.toDF()
        cb_sdf_w2v_final = cb_sdf_w2v.collect()
        #sc.stop()
        def cossim(v1, v2): 
            return np.dot(v1, v2) / np.sqrt(np.dot(v1, v1)) / (np.sqrt(np.dot(v2, v2))+.1)
        query_txt = Query ##user input, eg. noise/illegal
        query_df  = sc.parallelize([(1,query_txt)]).toDF(['index','Complaint_Type'])
        query_tok = regexTokFilter.transform(query_df)
        query_swr = stopwordFilter.transform(query_tok)
        query_vec = model.transform(query_swr)
        query_vec = query_vec.select('wordvectors').collect()[0][0]
        sim_rdd = sc.parallelize((i[0], i[1], i[2], float(cossim(query_vec, i[3]))) for i in cb_sdf_w2v_final)
        sim_df  = sqlContext.createDataFrame(sim_rdd).\
                    withColumnRenamed('_1', 'Unique_Key').\
                    withColumnRenamed('_2', 'Agency_Name').\
                    withColumnRenamed('_3', 'Complaint_Type').\
                    withColumnRenamed('_4', 'Similarity').\
                    orderBy("Similarity", ascending = False)
        search_results = sim_df.select('Agency_Name',"Complaint_Type","Similarity").distinct().sort(sim_df.Similarity.desc()).toPandas()
        sc.stop()
    ##output is a dataframe
        
    return render_template(
        "spark.html", form=form, 
        search_results=search_results)