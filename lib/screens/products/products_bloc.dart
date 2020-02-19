// Product List Bloc
// Author: openflutterproject@gmail.com
// Date: 2020-02-06

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:openflutterecommerce/repos/category_repository.dart';
import 'package:openflutterecommerce/repos/hashtag_repository.dart';
import 'package:openflutterecommerce/repos/models/category.dart';
import 'package:openflutterecommerce/repos/models/hashtag.dart';
import 'package:openflutterecommerce/repos/models/product.dart';
import 'package:openflutterecommerce/repos/product_repository.dart';
import 'package:openflutterecommerce/screens/products/products_event.dart';
import 'package:openflutterecommerce/screens/products/products_state.dart';
import 'package:openflutterecommerce/widgets/product_filter.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;
  final CategoryRepository categoryRepository;
  final HashtagRepository hashtagRepository;

  ProductBloc({
    @required this.categoryRepository,
    @required this.productRepository,
    @required this.hashtagRepository,
  }) : assert(productRepository != null);

  @override
  ProductState get initialState => ProductInitialState();

  @override
  Stream<ProductState> mapEventToState(ProductEvent event) async* {
    ProductStateData data = ProductStateData();
    if ( event is ProductStartEvent){
      data = getStateData(event.categoryId);
      yield ProductsLoadedState(
        isLoading: false,
        showSortBy: false,
        sortBy: SortBy.Popular,
        data: data);
    }
    else if ( event is ProductChangeSortByEvent){
      ProductsLoadedState state = this.state as ProductsLoadedState;
      yield state.copyWith(sortBy: event.sortBy, showSortBy: false);
    }
    else if ( event is ProductShowSortByEvent) {
      ProductsLoadedState state = this.state as ProductsLoadedState;
      yield state.copyWith(showSortBy: true);
    }
    else if (event is ProductLoadedEvent) {
      if (this.state is ProductsLoadedState) {
        ProductsLoadedState state = this.state as ProductsLoadedState;
        if (state.data.category.id != event.categoryId) {
          //Set state to loading
          yield state.copyWith(loading: true, 
            showSortBy: false);
          //Load data from repositories
          data = getStateData(event.categoryId);
          //set state to loaded and update data
          yield state.copyWith(
            data: data,
            loading: false,
            showSortBy: false);
        }
      }
    }
  }

  ProductStateData getStateData(int categoryId) {
    ProductStateData data = ProductStateData();

    data.products = productRepository.getProducts(categoryId);
    data.hashtags = hashtagRepository.getHashtags();
    data.category = categoryRepository.getCategoryDetails(categoryId);

    return data;
  }
}
