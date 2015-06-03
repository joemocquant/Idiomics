![Idiomics](https://github.com/joemocquant/Idiomics/blob/master/tagline.png)

# User Flow
![User Flow](https://github.com/joemocquant/Idiomics/blob/master/flow.png)

# Uses
![Uses](https://github.com/joemocquant/Idiomics/blob/master/uses.png)


<br>
# Idiomics Mobile Content API

<table>
  <tr>
    <td>version
    <td>1
  <tr>
    <td>prod URI
    <td>http://api.idiomicsapp.com/v1
  <tr>
    <td>staging URI
    <td>http://api-staging.idiomicsapp.com/v1
  <tr>
    <td>Content-type
    <td>application/json
</table>

1. [List collections](#list-collections)
    1. [Request](#request)
    2. [Response](#response)
2. [List panels](#list-panels)
    1. [Request](#request-1)
    2. [Response](#response-1)


## Collections

### List collections

#### Request
```
GET /collections
```

List all active collections in the order in which they should appear on device.

#### Response

##### Collection object

Field      | Type   | Description
-----------| ------ | -----------
id         | string | unique identifier for the collection
mashup_url | string | image url of a mashup of panels in the collection in the largest device required resolution (JPEG2000)
avg_color  | string | average color of the mashup image in the `rgb([0-255], [0-255], [0-255])` format
icon_url   | string | single-color white image representing the collection theme in the largest device required resolution (PNG)

The collection with the id `ALL` is a special collection which is always listed first and does not include an `icon_url` value.

##### Sample response

```json
[
	{
	  "id": "ALL",
	  "mashup_url": "http://images.idiomicsapp.com/collections/ALL/mashup.jpg",
	  "avg_color": "rgb(127,111,93)",
	  "icon_url": null
	},
	{
	  "id": "HAPPY",
	  "mashup_url": "http://images.idiomicsapp.com/collections/HAPPY/mashup.jpg",
	  "avg_color": "rgb(127,111,93)",
	  "icon_url": "http://images.idiomicsapp.com/collections/HAPPY/icon.png"
	},
	{
	  "id": "PUZZLED",
	  "mashup_url": "http://images.idiomicsapp.com/collections/PUZZLED/mashup.jpg",
	  "avg_color": "rgb(127,111,93)",
	  "icon_url": "http://images.idiomicsapp.com/collections/PUZZLED/icon.png"
	}
]
```

## Panels

### List panels

#### Request
```
GET /panels
```

List all panels, each with a list of zero or one balloon.

##### Query parameters

You can provide the following optional parameters to further restrict results:

Param      | Description
---------- | -----------
collection | unique identifier for a collection

Providing the `collection_id` parameter with the special id `ALL` will list all panels just as if no `collection_id` parameter was provided.

##### Example

`GET` on http://api.idiomicsapp.com/v1/panels?collection_id=HAPPY

Will list all the panels in the `HAPPY` collection.

#### Response

##### Panel object

Field      | Type      | Description
---------- | --------- | -----------
id         | string    | unique identifier for the panel
image_url  | string    | image url of the panel in original resolution with empty balloons (JPEG2000)
avg_color  | string    | average color of the panel at image_url in the `rgb([0-255], [0-255], [0-255])` format
dimensions | int[2]    | pixel width and height of the panel
balloons   | object[]  | empty list or list with a single balloon object

##### Balloon object

Field         | Type     | Description
------------- | -------- | -----------
polygon       | int[][2] | polygon approximation of the balloon, as a list of points (the first point is not repeated at the end)
inside_rect   | int[4]   | coordinates of the largest rectangle fitting inside the balloon, as the x and y coordinates of the start point, followed by width and height: `(x, y, width, height)`
outside_rect  | int[4]   | coordinates of the smallest rectangle which can wrap the ballon in the `(x, y, width, height)` format
bg_color      | string   | average of the balloon background color in the `rgb([0-255], [0-255], [0-255])` format

All coordinates start from the top-left of the panel which is `(0, 0)`.

##### Sample response

```json
[
  {
    "id": "COMIC_123/001-05",
    "image_url": "http://images.idiomicsapp.com/panels/COMIC_123/001-05.jpg",
    "avg_color": "rgb(127,111,93)",
    "dimensions": [321,776],
    "balloons": [
      {
        "polygon": [[272,513],[272,575],[368,575],[343,606],[243,406]],
        "inside_rect": [27,630,239,101],
        "outside_rect": [25,574,245,163],
        "bg_color": "rgb(254, 253, 253)"
      }
    ]
  },
  {
    "id": "COMIC_124/001-05",
    "image_url": "http://images.idiomicsapp.com/panels/COMIC_124/001-05.jpg",
    "avg_color": "rgb(127,111,93)",
    "dimensions": [321,776],
    "balloons": []
  }
]
```
