part of flutter_mapbox_autocomplete;

class MapBoxAutoCompleteWidget extends SearchDelegate {
  /// Mapbox API_TOKEN
  final String apiKey;

  /// Hint text to show to users
  final String? hint;

  /// Callback on Select of autocomplete result
  final void Function(MapBoxPlace place)? onSelect;

  /// if true will dismiss autocomplete widget once a result has been selected
  final bool closeOnSelect;

  /// The callback that is called when the user taps on the search icon.
  // final void Function(MapBoxPlaces place) onSearch;

  /// Language used for the autocompletion.
  ///
  /// Check the full list of [supported languages](https://docs.mapbox.com/api/search/#language-coverage) for the MapBox API
  final String language;

  /// The point around which you wish to retrieve place information.
  final Location? location;

  /// Limits the no of predections it shows
  final int? limit;

  ///Limits the search to the given country
  ///
  /// Check the full list of [supported countries](https://docs.mapbox.com/api/search/) for the MapBox API
  final String? country;

  MapBoxAutoCompleteWidget({
    required this.apiKey,
    this.hint,
    this.onSelect,
    this.closeOnSelect = true,
    this.language = "en",
    this.location,
    this.limit,
    this.country,
  });

  Future<Predections> _getPlaces(String input) async {
    if (input.length > 0) {
      String url =
          "https://api.mapbox.com/geocoding/v5/mapbox.places/$input.json?access_token=${apiKey}&cachebuster=1566806258853&autocomplete=true&language=${language}&limit=${limit}";
      if (location != null) {
        url += "&proximity=${location!.lng}%2C${location!.lat}";
      }
      if (country != null) {
        url += "&country=$country";
      }
      final response = await http.get(Uri.parse(url));
      // print(response.body);
      // // final json = jsonDecode(response.body);
      final predictions = Predections.fromRawJson(response.body);

      return predictions;
    } else {
      return Predections.empty();
    }
  }

  // void _selectPlace(MapBoxPlace prediction) async {
  //   // Calls the `onSelected` callback
  //   widget.onSelect!(prediction);
  //   if (widget.closeOnSelect) Navigator.pop(context);
  // }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query == "" ? null : _getPlaces(query),
      builder: (context, AsyncSnapshot<Predections> snapshot) => query == ''
          ? Container(
              padding: EdgeInsets.all(16.0),
              child: Text('Enter your address'),
            )
          : snapshot.hasData
              ? ListView.separated(
                  separatorBuilder: (cx, _) => Divider(),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  itemCount: snapshot.data!.features!.length,
                  itemBuilder: (ctx, i) {
                    MapBoxPlace _singlePlace = snapshot.data!.features![i];
                    return ListTile(
                      title: Text(_singlePlace.text!),
                      subtitle: Text(_singlePlace.placeName!),
                      onTap: () {
                        close(context, _singlePlace);
                      },
                    );
                  },
                )
              : Container(child: Text('Loading...')),
    );
  }
}
