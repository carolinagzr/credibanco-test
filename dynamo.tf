resource "aws_dynamodb_table" "example" {
  name             = "pedidosDB"
  hash_key         = "idOrder"
  billing_mode     = "PROVISIONED"
  read_capacity = 20
  write_capacity = 20
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "idOrder"
    type = "N"
  }
 
 
}
resource "aws_dynamodb_table_item" "example" {
  table_name = aws_dynamodb_table.example.name
  hash_key   = aws_dynamodb_table.example.hash_key

  item = <<ITEM
{
  "idOrder": {"N": "44444"},
  "product": {"S": "manzanas"},
  "quantity": {"N": "2"},
  "status": {"S": "pending"}

}
ITEM
}