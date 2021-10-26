CREATE TABLE Neighborhoods (
  id SERIAL UNIQUE PRIMARY KEY,
  neighborhood varchar UNIQUE
);

CREATE TABLE Address_info (
  id SERIAL UNIQUE PRIMARY KEY,
  borough int,
  neighborhood_id int REFERENCES neighborhoods (id),
  address varchar,
  apartment_nubmer varchar,
  zip_code int
);

CREATE TABLE Building_info (
  id SERIAL UNIQUE PRIMARY KEY,
  residential_units int,
  commercial_units int,
  total_units int,
  land_square int,
  gross_square int,
  year_build int
);

CREATE TABLE Tax (
	tax varchar UNIQUE PRIMARY KEY,
	description varchar
);

CREATE TABLE Property_sales (
  id SERIAL UNIQUE PRIMARY KEY, 
  building_class_category varchar,
  tax_class_at_time_of_sale varchar REFERENCES Tax (tax),
  id_address int REFERENCES Address_info (id),
  id_building int REFERENCES Building_info (id)
);

CREATE TABLE Sale (
  id SERIAL UNIQUE PRIMARY KEY,
  price money,
  date date,
  id_property int REFERENCES Property_sales (id)
);

CREATE TABLE buffer(
	BOROUGH int,
	NEIGHBORHOOD varchar,
	BUILDING_CLASS_CATEGORY varchar,
	ADDRESS varchar,
	APARTMENT_NUMBER varchar,
	ZIP_CODE int,
	RESIDENTIAL_UNITS int,
	COMMERCIAL_UNITS int,
	TOTAL_UNITS int,
	LAND_SQUARE_FEET int,
	GROSS_SQUARE_FEET int,
	YEAR_BUILT int,
	TAX_CLASS_AT_TIME_OF_SALE varchar,
	SALE_PRICE money, 
	SALE_DATE date
);






