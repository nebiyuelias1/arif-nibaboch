GET https://www.googleapis.com/books/v1/volumes
[QueryStringParams]
q: The stranger
orderBy: relevance
printType: books
maxResults: 5
key: {{google_books_api_key}}

HTTP 200
[Asserts]
jsonpath "$.items" exists
