import 'package:filter_bloc_demo/data/category_data.dart';
import 'package:filter_bloc_demo/model/category_model.dart';
import 'package:filter_bloc_demo/model/item_list_view_model.dart';
import 'package:filter_bloc_demo/model/price_list_view_model.dart';
import 'package:filter_bloc_demo/view/home/bloc/filter_bloc.dart';
import 'package:filter_bloc_demo/view/home/bloc/filter_event.dart';
import 'package:filter_bloc_demo/view/home/bloc/filter_state.dart';
import 'package:filter_bloc_demo/view/home/widgets/list_view_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ItemListViewModel> itemList = [];
  List<CategoryModel> categoryList = [];
  List<PriceListViewModel> priceList = [];
  int isSelected = 0;

  late FilterBloc _bloc;

  //! Widget Lifecycle Method
  @override
  void initState() {
    _bloc = context.read<FilterBloc>();
    _bloc.add(GetListEvent());
    super.initState();
  }

  //! Build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter Bloc Demo"),
      ),
      body: SafeArea(child: _blocBuilder()),
    );
  }

  //! Widget Methods

  Widget _blocBuilder() => BlocBuilder<FilterBloc, FilterState>(
        builder: (context, state) {
          if (state is FilterGetListState) {
            categoryList = state.categoryList;
            priceList = state.priceList;
            itemList = state.itemList;
          }
          if (state is CategoryListChangeState) {
            categoryList = state.list;
          }
          if (state is PriceListChangeState) {
            priceList = state.list;
          }
          if (state is ItemListChangeState) {
            itemList = state.list;
          }
          return CustomScrollView(
            slivers: [
              _filterOptionsCategoryAndPrice(),
              state is FilterLoadingState
                  ? _loadingIndicator()
                  : _itemListView()
            ],
          );
        },
      );

  Widget _filterOptionsCategoryAndPrice() => SliverToBoxAdapter(
        child: Column(
          children: [
            _categoryList(),
            const SizedBox(height: 20),
            _priceListView(),
            const SizedBox(height: 20),
          ],
        ),
      );

  Widget _loadingIndicator() => const SliverToBoxAdapter(
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(),
          ),
        ),
      );

  Widget _categoryList() => SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categoryData.length,
          itemBuilder: (ctx, index) {
            return _categoryCard(index);
          },
        ),
      );

  Widget _categoryCard(int index) => ListViewCard(
        onTap: () {
          _bloc.add(CategoryListSelectEvent(index: index));
          _bloc.add(FilterItemEvent());
        },
        cardWidth: 120,
        color: categoryList[index].isSelected
            ? Colors.greenAccent
            : Colors.purple[20],
        showListProperty: categoryList[index].name,
      );

  Widget _priceListView() => SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: priceList.length,
          itemBuilder: (ctx, index) {
            return _priceCard(index);
          },
        ),
      );

  Widget _priceCard(int index) => ListViewCard(
        onTap: () {
          isSelected = index;
          _bloc.add(PriceListSelectEvent(index: index));
          _bloc.add(FilterItemEvent());
        },
        cardWidth: 120,
        color: isSelected == index ? Colors.redAccent : Colors.purple[20],
        showListProperty: priceList[index].price,
      );

  Widget _itemListView() => SliverList.builder(
        itemCount: itemList.length,
        itemBuilder: (ctx, index) {
          return _itemListTile(index);
        },
      );

  Widget _itemListTile(int index) => Card(
        child: ListTile(
          leading: _leadingLikeButton(index),
          title: Text(itemList[index].name),
          subtitle: Text(itemList[index].category.name.toUpperCase()),
          trailing: _trailingItemPrice(index)
        ),
      );

  Widget _leadingLikeButton(int index) => IconButton(
        icon: itemList[index].isFavorite
            ? const Icon(Icons.favorite)
            : const Icon(Icons.favorite_border),
        onPressed: () {
          _bloc.add(ItemLikedEvent(index: index));
        },
      );

  Widget _trailingItemPrice(int index) => Text(
        "Rs. ${itemList[index].price}",
        style: const TextStyle(color: Colors.black),
      );
}
