import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/people.dart';
import '../models/people_list.dart';
import '../components/person_item.dart';
import '../components/page_options.dart';
import '../services/fetch_service.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({Key? key}) : super(key: key);

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  bool? isLoaded = false;
  bool? canUpdate = false;

  void _handleSearch(List<People> arg, Getter getter) async {
    final pplClass = Provider.of<PeopleList>(context, listen: false);
    final id = pplClass.id + 1;
    pplClass.setInfo(arg, getter, id);
    
    setState(() {
      canUpdate = true;
    }); 
  }

  @override
  void initState() {
    super.initState();
    
    getData();
  }

  void getData() async {
    final pplClass = Provider.of<PeopleList>(context, listen:false);
    final num = pplClass.id + 1;

    if (pplClass.id == 0) {
      final data = await FetchService().getPeople();
      pplClass.setFavorites();
      pplClass.setCachedPeople();
      pplClass.setInfo(data!.results as List<People>, data, num);
    }

    if (pplClass.people.isNotEmpty) {
      setState(() {
        isLoaded = true;
      });
    }  
  }

  @override
  Widget build(BuildContext context) {
    final pplClass = Provider.of<PeopleList>(context);

    final ppl = pplClass.people;
    return Scaffold(
      body: Column(
        children: [
          if (isLoaded != null && isLoaded == true)
            IconButton(
              icon: const Icon(Icons.book),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (ctx) => Column(
                    children: <Widget>[
                      PageOptions(
                        onSearch: _handleSearch,
                      ),
                    ]
                  ),
                );
              },
            ),
          Expanded(
            child: GridView(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              children: <Widget>[
                if (isLoaded != null && isLoaded == true)
                  for (var i = 0; i < ppl.length; i++)
                    PersonItem(
                      person: ppl[i],
                    )
                else
                  const Text('Loading...')
              ]
            ),
          ),
        ],
      ),
    );
  }
}