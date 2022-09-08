import 'package:flutter/material.dart';
import '../services/fetch_service.dart';
import '../models/people.dart';
import '/components/pages.dart';

class Options extends StatefulWidget {
  const Options({required this.onSearch, required this.info, Key? key}) : super(key: key);

  final void Function(List<People>?, Getter?, String?) onSearch;
  final Getter? info;

  @override
  State<Options> createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  final searchController = TextEditingController();

  void _handleSearch() async {
    final String name = searchController.text;
    
    final data = name.isNotEmpty 
    ? await FetchService().getPeopleByName(name)
    : await FetchService().getPeople();

    widget.onSearch(data!.results, data, name);
  }

  @override
  Widget build(BuildContext context) {
    final TextField searcher = TextField(
      maxLength: 50,
      controller: searchController,
      onSubmitted: (_) =>_handleSearch(),
      obscureText: false,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        labelStyle: const TextStyle(color: Colors.white), 
        labelText: 'Name',
      ),
      style: const TextStyle(
        color: Colors.white70,
      )
    );

    final ElevatedButton btn = ElevatedButton(
      onPressed: _handleSearch,
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).primaryColor,
        textStyle: const TextStyle(
          fontSize: 20, 
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)
        ),
        side: BorderSide(
          width: 1.0,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      child: Text(
        'Search', 
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary
        )
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          searcher,
          const SizedBox(height: 10),
          btn,
          Pages(
            info: widget.info!, 
            updState: widget.onSearch, 
            filter: searchController.text,
          ),
        ],
      ),
    );
  }
}