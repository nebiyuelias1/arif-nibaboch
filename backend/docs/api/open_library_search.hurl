GET https://openlibrary.org/search.json
[QueryStringParams]
q: 12 rules for life
limit: 5
fields: title,author_name,cover_i,isbn,publisher,first_publish_year,number_of_pages_median,subject,key,first_sentence

HTTP 200
[Asserts]
jsonpath "$.docs" exists
