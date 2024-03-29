import 'package:elec_mart_customer/components/app_bar.dart';
import 'package:elec_mart_customer/components/category.dart';
import 'package:elec_mart_customer/components/drop_down_widget.dart';
import 'package:elec_mart_customer/components/text_field.dart';
import 'package:elec_mart_customer/constants/Colors.dart';
import 'package:elec_mart_customer/models/CategoriesModel.dart';
import 'package:elec_mart_customer/screens/graphql/categories.dart';
import 'package:elec_mart_customer/state/app_state.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

class FilterModal extends StatefulWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChange;

  const FilterModal({this.selectedCategory, this.onCategoryChange});

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  bool isFilter = false;

  AnimationController animationController;
  Animation<Offset> animationOffset;

  final searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));

    animationOffset = Tween<Offset>(end: Offset(0, 0), begin: Offset(0.0, -1.0))
        .animate(animationController);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: <Widget>[
          SlideTransition(
            position: animationOffset,
            child: Container(
              color: WHITE_COLOR,
              height: 260,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              child: isFilter ? filterColumn() : getCategoryQuery(),
            ),
          ),
          CustomAppBar(
            isFilter: isFilter,
            isExpanded: isExpanded,
            selectedName: widget.selectedCategory,
            iconRight: isExpanded ? FeatherIcons.x : null,
            onCategoryPressed: () {
              if (!isExpanded)
                animationController.forward();
              else
                animationController.reverse();
              setState(() {
                if (!isExpanded) {
                  isFilter = false;
                }
                isExpanded = !isExpanded;
              });
            },
            onFilterPressed: () {
              if (!isExpanded)
                animationController.forward();
              else
                animationController.reverse();
              setState(() {
                if (!isExpanded) {
                  isFilter = true;
                }
                isExpanded = !isExpanded;
              });
            },
          ),
        ],
      ),
    );
  }

  Column filterColumn() {
    return Column(
      children: <Widget>[
        Container(margin: EdgeInsets.only(top: 65)),
        searchField(),
        rangeSliders(),
        SizedBox(height: 5),
        sortBy(),
      ],
    );
  }

  Widget searchField() {
    final appState = Provider.of<AppState>(context);
    if (appState.getSearchText == "") searchTextController.clear();
    return CustomTextField(
      controller: searchTextController,
      labelText: "Search for items",
      onChanged: (val) {
        appState.setsearchText(val);
      },
    );
  }

  Widget rangeSliders() {
    final appState = Provider.of<AppState>(context);

    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                "Price Range",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Expanded(
                child: RangeSlider(
                  values: appState.rangeValue,
                  min: 0,
                  max: 100000,
                  divisions: 10,
                  activeColor: PRIMARY_COLOR,
                  inactiveColor: LIGHT_BLUE_COLOR,
                  onChanged: (RangeValues val) {
                    appState.setRangeValues(val);
                  },
                ),
              ),
            ],
          ),
          Text(
            "₹ ${appState.rangeValue.start}- ₹ ${appState.rangeValue.end}",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  Widget sortBy() {
    final appState = Provider.of<AppState>(context);
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Sort by",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          DropDownWidget(
            hint: "Price (low to high)",
            itemList: ["Price (low to high)", "Price (high to low)", "Newest"],
            onChanged: (val) {
              appState.setSortType(val);
            },
            itemValue: appState.getsortType,
          )
        ],
      ),
    );
  }

  Widget getCategoryQuery({bool category = false}) {
    final appState = Provider.of<AppState>(context);
    return Query(
      options: QueryOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: getCategories,
        context: {
          'headers': <String, String>{
            'Authorization': 'Bearer ${appState.jwtToken}',
          },
        },
        pollInterval: 30,
      ),
      builder: (QueryResult result, {VoidCallback refetch}) {
        if (result.loading) return Center(child: CupertinoActivityIndicator());
        if (result.hasErrors)
          return Center(child: Text("Oops something went wrong"));
        if (result.data != null && result.data['getCategories'] != null) {
          List categoryList = result.data['getCategories'];
          List<CategoriesModel> categories;

          categories = categoryList
              .map((item) => CategoriesModel.fromJson(item))
              .toList();

          categories.insert(0, CategoriesModel(image: "", name: "All"));

          return categoryColumn(categories);
        }
        return Container();
      },
    );
  }

  Widget categoryColumn(List<CategoriesModel> categories) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(top: 45),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.8,
          crossAxisCount: 2,
          crossAxisSpacing: 1,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) => InkWell(
            onTap: () {
              widget.onCategoryChange(categories[index].name);
              isExpanded = false;
              isFilter = false;
              animationController.reverse();
            },
            child: Category(
                categoryImage: categories[index].image,
                name: categories[index].name,
                selected: widget.selectedCategory == categories[index].name)),
      ),
    );
  }
}
