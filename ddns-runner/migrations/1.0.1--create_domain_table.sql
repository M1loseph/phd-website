CREATE TABLE "Domains" (
  "id" BIGSERIAL PRIMARY KEY,
  "domain_name" VARCHAR(255) NOT NULL UNIQUE,
);

INSERT INTO "Domains"("domain_name")
VALUES (1, 'phdwebsite');


ALTER TABLE "IpUpdateResults"
ADD "domain_id" BIGINT REFERENCES "Domains"("id") NOT NULL
WITH DEFAULT 1;
