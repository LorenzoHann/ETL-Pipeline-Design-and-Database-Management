
1. What are the top 3 areas in New York City that have the most complaints ?

select count(tt.unique_key) as total, city
from timerecord tt
left join incident_address ia
on tt.unique_key = ia.unique_key
left join address add
on ia.address_id = add.address_id
where city is not null
group by city
order by count(tt.unique_key) desc
limit(3);

2. Which bridge has the most incidents?

select count(tr.unique_key), bridge_highway_name
from timerecord tr
left join bh_incident bi
on tr.unique_key = bi.unique_key
left join bridge_highway bh
on bi.bridge_highway_id = bh.bridge_highway_id
where bridge_highway_name is not null
group by bridge_highway_name
order by count(tr.unique_key) desc
limit(5);

3. Which boroughs have the most call incidents?

select borough,count(tr.unique_key) as total
from timerecord tr
left join incident_address ia
on tr.unique_key = ia.unique_key
left join geovalidation geo
on ia.geolocation_id = geo.geolocation_id
where borough is not null
group by borough
order by count(tr.unique_key) desc
limit(3);


4. What is the daily number of 311 calls received by each agency and each complaint type?

with table_2 as (select tt.unique_key, agency, agency_name, complaint_type, created_date
from timerecord tt
left join
complaint_agency ca
on tt.unique_key = ca.unique_key
left join agency aa
on ca.agency_id = aa.agency_id
left join complaint_type ct
on ca.type_id = ct.type_id
left join incident_address ia
on tt.unique_key = ia.unique_key)
select agency, agency_name, complaint_type, 
count(unique_key)/nullif((max(created_date)-min(created_date)),0)
from table_2
group by agency, agency_name,complaint_type
order by count(unique_key) desc ;





5. Which agency has the most incidents?

select distinct aa.agency, aa.agency_name, count(created_date) as count
from agency aa
join complaint_agency ca on ca.agency_id = aa.agency_id
join timerecord tt on ca.unique_key = tt.unique_key
group by agency,agency_name
order by count desc;

6. Which complaint type has the most calls in each region?

create view region_complaints as
select city,complaint_type, count(*) over(partition by complaint_type) as total
from timerecord tt
left join complaint_agency ca
on tt.unique_key = ca.unique_key
left join complaint_type ct
on ca.type_id = ct.type_id 
left join incident_address ia
on tt.unique_key = ia.unique_key
left join address add on
ia.address_id = add.address_id
where city is not null
group by city, complaint_type
order by city, total desc;

select city, complaint_type, total 
from (
  select * ,rank() over(partition by city order by total desc) as rk
  from region_complaints
) x
where rk = 1


7. What are the most complaints reported in Manhattan?

select complaint_type, count(*) as total from timerecord tt
left join incident_address ia
on tt.unique_key = ia.unique_key
left join complaint_agency ca
on tt.unique_key = ca.unique_key 
left join complaint_type ct
on ca.type_id = ct.type_id
left join address add
on ia.address_id = add.address_id
where city = 'MANHATTAN'
group by complaint_type
order by total desc;

8. What is the accumulated sum for each type of complaint by time series?

select complaint_type,created_date, count(tr.unique_key) 
over(partition by complaint_type order by tr.created_date desc
rows between current row and unbounded following) as accumulate_count				 
from timerecord tr
left join complaint_agency ca
on tr.unique_key = ca.unique_key
left join complaint_type ct
on ca.type_id = ct.type_id
group by complaint_type,created_date,tr.unique_key;


9. What's the average resolution speed for each complaint type? 

select ct.complaint_type, avg(t.closed_date-t.created_date) as resolved_in_days
from timerecord t
left join complaint_agency ca
on t.unique_key=ca.unique_key
left join complaint_type ct
on ca.type_id=ct.type_id
WHERE t.closed_date is not NULL
group by ct.complaint_type
order by resolved_in_days desc;



10. Which agency solves the problem fastest?

select a.agency,avg(t.closed_date-t.created_date) as resolved_in_days
from timerecord t
left join complaint_agency ca
on t.unique_key=ca.unique_key
left join agency a
on ca.agency_id=a.agency_id
WHERE t.closed_date is not NULL
group by a.agency
order by resolved_in_days;








