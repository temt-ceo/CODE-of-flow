import 'package:flutter/material.dart';

CardItemList cardItemList = CardItemList(cardItems: [
  CardItem(
    id: 1,
    name: "Beach BBQ Burger",
    imgUrl:
        "https://hips.hearstapps.com/pop.h-cdn.co/assets/cm/15/05/480x240/54ca71fb94ad3_-_5summer_skills_burger_470_0808-de.jpg",
  ),
  CardItem(
    id: 2,
    name: "Dudleys",
    imgUrl:
        "https://b.zmtcdn.com/data/pictures/chains/8/18427868/1269c190ab2f272599f8f08bc152974b.png",
  ),
  CardItem(
    id: 3,
    name: "Golf Course",
    imgUrl: "https://static.food2fork.com/burger53be.jpg",
  ),
  CardItem(
    id: 4,
    name: "Chilly Cheeze Burger",
    imgUrl: "https://static.food2fork.com/36725137eb.jpg",
  ),
  CardItem(
    id: 5,
    name: "Beach BBQ Burger",
    imgUrl: "https://static.food2fork.com/turkeyburger300x200ff84052e.jpg",
  ),
  CardItem(
    id: 6,
    name: "Beach BBQ Burger",
    imgUrl:
        "https://cdn.pixabay.com/photo/2018/03/04/20/08/burger-3199088__340.jpg",
  ),
]);

class CardItemList {
  List<CardItem> cardItems;

  CardItemList({required this.cardItems});
}

class CardItem {
  int id;
  String name;
  String imgUrl;
  int quantity;

  CardItem(
      {required this.id,
      required this.name,
      required this.imgUrl,
      this.quantity = 1});

  void incrementQuantity() {
    this.quantity = this.quantity + 1;
  }

  void decrementQuantity() {
    this.quantity = this.quantity - 1;
  }
}
