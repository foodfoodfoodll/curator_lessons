CREATE TABLE Sale (
  sale_id SERIAL PRIMARY KEY,
  price money NOT NULL,
  date date NOT NULL,
  property_id int NOT NULL
);

CREATE TABLE Property_info (
  property_id SERIAL PRIMARY KEY,
  building_class_category varchar,
  tax varchar,
  address_id int NOT NULL,
  building_id int NOT NULL
);

CREATE TABLE Tax (
  tax varchar PRIMARY KEY,
  description varchar NOT NULL
);

CREATE TABLE Address_info (
  address_id SERIAL PRIMARY KEY,
  neighborhood_id int NOT NULL,
  address varchar NOT NULL,
  apartment_number varchar,
  zip_code integer NOT NULL
);

CREATE TABLE Building_info (
  building_id SERIAL PRIMARY KEY,
  residential_units integer NOT NULL,
  commercial_units integer NOT NULL,
  total_units integer NOT NULL,
  land_square integer NOT NULL,
  gross_square integer NOT NULL,
  year_built integer NOT NULL
);

CREATE TABLE Neighborhoods (
  neighborhood_id SERIAL PRIMARY KEY,
  neighborhood varchar NOT NULL,
  borough int NOT NULL
);

ALTER TABLE Sale ADD FOREIGN KEY (property_id) REFERENCES Property_info(property_id);

ALTER TABLE Property_info ADD FOREIGN KEY (address_id) REFERENCES Address_info (address_id);

ALTER TABLE Address_info ADD FOREIGN KEY (neighborhood_id) REFERENCES Neighborhoods (neighborhood_id);

ALTER TABLE Property_info ADD FOREIGN KEY (building_id) REFERENCES Building_info (building_id);

ALTER TABLE Property_info ADD FOREIGN KEY (tax) REFERENCES Tax (tax);

CREATE TABLE buffer(
	borough int,
	neighborhood varchar,
	building_class_category varchar,
	address varchar,
	apartment_number varchar,
	zip_code int,
	residential_units int,
	commercial_units int,
	total_units int,
	land_square_feet int,
	gross_square_feet int,
	year_built int,
	tax_class_at_time_of_sale varchar,
	sale_price money, 
	sale_date date	
);

