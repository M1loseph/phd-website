-- TEXT type is used as a primary key since sqlite can't store 64 bit unsigned integer
-- https://www.sqlite.org/datatype3.html
CREATE TABLE "backup_metadata" (
	"backup_id" TEXT PRIMARY KEY,
	"host" TEXT NOT NULL,
	"created_at" TEXT NOT NULL,
	"backup_size_bytes" TEXT NOT NULL,
	"backup_target" TEXT NOT NULL,
	"backup_type" TEXT NOT NULL,
	"backup_format" TEXT NOT NULL
)
