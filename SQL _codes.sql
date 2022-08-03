CREATE TABLE complaint_type
(type_id integer,
complaint_type varchar(50),
primary key (type_id)
);
    
CREATE TABLE complaint_descriptor
(descriptor_id integer, 
 descriptor varchar(100),
 primary key (description_id)
);

CREATE TABLE agency
( agency_id integer,
 agency varchar(50),
 agency_name varchar(100),
 primary key (agency_id)
);
    
CREATE TABLE channels
(	channel_id integer,
	open_data_channel_type varchar(30),
	primary key(channel_id)
);

CREATE TABLE complaint_agency
(type_id integer,
unique_key integer,
descriptor_id integer,
PRIMARY KEY (type_id,unique_key,descriptor_id),
FOREIGN KEY (type_id) REFERENCES complaint_type,
FOREIGN KEY (unique_key) REFERENCES timerecord,
FOREIGN KEY (descriptor_id) REFERENCES complaint_descriptor
);

CREATE TABLE request_channel
(   unique_key integer,
	channel_id integer,
	PRIMARY KEY (unique_key,channel_id),
	FOREIGN KEY (unique_key) REFERENCES timerecord,
	FOREIGN KEY (channel_id) REFERENCES channels
);

CREATE TABLE resolutions
( resolution_id integer,
 resolution_description varchar(1000),
 primary key (resolution_id)
);

CREATE TABLE request_resolution
( unique_key integer,
 resolution_id integer,
 resolution_action_update_date date,
 primary key (unique_key,resolution_id),
 FOREIGN KEY (unique_key) REFERENCES timerecord,
 FOREIGN KEY (resolution_id) REFERENCES resolutions
);

CREATE TABLE timerecord
(unique_key integer,
 created_date date,
 due_date date,
 closed_date date,
 status varchar(20),
  primary key (unique_key)
);

CREATE TABLE address
(	address_id integer,
	incident_zip integer,
	incident_address varchar(100),
	street_name varchar(50),
	cross_street varchar(50),
	intersection_street varchar(50),
	city varchar(20),
	landmark varchar(50),
	PRIMARY KEY (address_id)
);


CREATE TABLE bh_incident
( bhincident_id int,
  bridge_highway_id int,
  unique_key int
  primary key(bhincident_id),
  foreign key(bridge_highway_id)references bridge highway,
  foreign key(unique_key)references timerecord
);

CREATE TABLE park_incident
( pincident_id int,
  park_id int,
  unique_key int,
  primary key(pincident_id),
  foreign key(park_id)references park,
  foreign key(unique_key)references timerecord   
);

CREATE TABLE geovalidation
( geolocation_id int
  community_board varchar(50),
  bbl varchar(20),
  borough varchar(50),
  x_coordinate decimal (10,2),
  y_coordinate decimal (10,2),
  primary key(geolocation_id)   
);

CREATE TABLE incident_address
(unique_key int,
 address_id int,
 location_type_id int,
 geolocation_id int,
 foreign key(unique_key)references timerecord,
 foreign key(address_id)references addresses,
 foreign key(location_type_id)references location_type,
 foreign key(geolocation_id)references geovalidation    
);

CREATE TABLE bridge_highway (
	bridge_highway_id int primary key,
	bridge_highway_name varchar(100),
	bridge_highway_direction varchar(255),
	road_ramp varchar(100),
	bridge_highway_segment varchar(100)
);

CREATE TABLE park (
	park_id int primary key,
	park_facility varchar(40),
	park_borough varchar(30)
);

CREATE TABLE geobased_Location (
	geolocation_id int primary key,
	latitude decimal (9,6),
	longitude decimal (9,6),
	location varchar(60)
);

CREATE TABLE location_type (
	location_type_id int primary key,
	location_type varchar(30)
);
	