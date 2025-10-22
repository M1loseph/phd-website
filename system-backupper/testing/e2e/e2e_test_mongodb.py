from pymongo import MongoClient
import requests

def test_create_backup_and_restore_it_to_collection_that_contains_documents():
    # given
    source_client = MongoClient("mongodb://username:password@localhost:27017/")
    
    source_db = source_client["testdb"]
    source_collection = source_db["test_collection"]
    source_collection.insert_many([
        {
           "name": "first",
           "value": 42
        },
        {
           "name": "second",
           "value": 43
        },
    ])
    target_client = MongoClient("mongodb://username:password@localhost:27016/")
    target_db = target_client["testdb"]
    target_collection = target_db["test_collection"]
    target_collection.insert_one({
        "name": "third",
        "value": 44
    })

    # when
    response = requests.post("http://localhost:2000/api/v1/backups/mongodbSource")
    response.raise_for_status()
    response_body = response.json()
    backup_id = response_body["backup_id"]

    response = requests.post(f"http://localhost:2000/api/v1/targets/mongodbTarget/backups/{backup_id}")
    response.raise_for_status()

    # then
    restored_documents = list(target_collection.find({}, {"_id": 0}).sort("value", 1))
    assert restored_documents == [
        {
            "name": "first",
            "value": 42
        },
        {
            "name": "second",
            "value": 43
        },
        {
            "name": "third",
            "value": 44
        }
    ]

