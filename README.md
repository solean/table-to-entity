# Build a Hibernate entity skeleton from an Oracle table describe

##### Usage:
- copy and paste table describe into a text file
- ruby main.rb PATH_TO_DESCRIBE_FILE ENTITY_NAME
    - example: ruby main.rb ~/Desktop/security.txt SecurityEntity.java

##### To do:
- Postgres support
- parse DDLs instead/in addition to describes?
- support more/all data types:
  - since I wrote this primarily because I was too lazy to build the entity for a single very large table, this only supports 3 types at the moment (VARCHAR2, NUMBER, DATE)
