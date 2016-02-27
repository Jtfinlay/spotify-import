# spotify-import
Import your playlist into Spotify from existing metadata (in this case Google Play)

The imported metadata is expected to be of the form:

```
[ 
  {
    "title": "400 Lux",
    "artist": "Lorde",
    "album": "Pure Heroine",
  },
  {
    "title": "Formidable",
    "artist": "Stromae",
    "album": "Racine Carrée",
  },
  ...
]
```

because that's how my Google Music playlist exported. If you're transfering from Google Music as well, this [this gist worked well](https://gist.github.com/jmiserez/c9a9a0f41e867e5ebb75) for my use. Additional metadata parameters are ignored.
