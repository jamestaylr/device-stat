CREATE TYPE metric AS ENUM ('cpu', 'memory', 'disk');

CREATE TABLE metrics (
    id	        serial PRIMARY KEY,
    datetime    timestamp WITH TIME ZONE NOT NULL,
    type        metric NOT NULL,
    value       decimal NOT NULL
);

CREATE TABLE constants (
    id          serial PRIMARY KEY,
    type        metric NOT NULL,
    value       decimal NOT NULL
);

CREATE INDEX "unique_metric" ON metrics (datetime, type, value);
