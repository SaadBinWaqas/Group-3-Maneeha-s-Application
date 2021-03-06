import 'package:first_proj/pages/emptyCartNew.dart';
import 'package:first_proj/util/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:first_proj/pages/checkout.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// PURPOSE:
// Create the cart page

// This Function creates a ListView of the items in the user's shopping cart
class ShoppingCart extends StatefulWidget {

  var user;
  ShoppingCart({this.user});
  
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('UserCart').document(widget.user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data['productID'].toList().length <= 0) {
          return EmptyCart();
        } else {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Loading();
          } 
          else {
            return Scaffold(
              // =========== START APP BAR ===========
              appBar: AppBar(
                leading: BackButton(
                  color: Colors.black,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(
                  "My Cart",
                  style: TextStyle(
                    color: Colors.black,
                  )
                ),
                centerTitle: true,
                backgroundColor: Colors.white.withOpacity(0.97),
              ),
              // =========== END APP BAR ===========

              // ================= START LIST VIEW =================
              body: ListView.builder(
                itemCount: snapshot.data['productID'].toList().length,
                // Calls the same function to make the details of one product
                itemBuilder: (BuildContext context, var index) {
                  return Container(
                    padding: EdgeInsets.only(top: 15),
                    child: Column(
                      children: <Widget>[
                        BuildCard(
                          snapshot.data['products'][index]['name'].toString(),
                          snapshot.data['products'][index]['image'][0].toString(),
                          snapshot.data['products'][index]['price'].toString(),
                          snapshot.data['products'][index]['size'].toString(),
                          widget.user,
                        ),
                        Divider(thickness: 0.7,)
                      ],
                    ),
                  );
                },
                scrollDirection: Axis.vertical,
              ),
              // ================= END LIST VIEW =================

              // Calls function at the bottom of this file to create the bottom navigation bar.
              bottomNavigationBar: BottomNavigation(user: widget.user),
            );
          }
        }
      }
    );
  }
}

// Builds one product information
class BuildCard extends StatelessWidget {

  String prodName;
  String prodImg;
  String prodPrice;
  String prodSize;
  var user;

  BuildCard(String prodName, String prodImg, String prodPrice, String prodSize, var user) {
    this.prodName = prodName;
    this.prodImg = prodImg;
    this.prodPrice = prodPrice;
    this.prodSize = prodSize;
    this.user = user;
    
  }
  
  static const sizeList = ['Small', 'Medium', 'Large'];
  var currentSelected = "Small";

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('UserCart').document(user.uid).snapshots(),
      builder: (context, snapshot) {
        return Row(
          children: <Widget>[

            // IMAGE
            Padding(
             padding: const EdgeInsets.all(12.0),
               child: Container(
                alignment: Alignment(-1,0),
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(this.prodImg),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(prodImg),
                ),
              ),
            ),

            // INFORMATION
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                // NAME
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    child: Text(prodName, style: TextStyle(fontSize: 20,)),
                  ),
                ),
                SizedBox(height: 15,),

                // PRICE
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    child: Text('Rs. $prodPrice', style: TextStyle(fontSize: 20,)),
                  ),
                ),

                // SIZE
                Container(
                  child: Align(
                    alignment: Alignment(0,-0.1),
                    child: RaisedButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(5),
                          side: BorderSide(color: Colors.black)
                      ),
                      color: Colors.white,
                      child:  Text('Size: $prodSize'),
                      onPressed: (){},
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }
    );
  }
}




// Bottom navigation bar for total price and Checkout button
class BottomNavigation extends StatefulWidget {

  var user;
  BottomNavigation({this.user});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {

  // For the dropdown list
  static const sizeList = ['Small', 'Medium', 'Large'];
  var currentSelected = "Small";

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            // PRICE
            FittedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget> [
                  Text(
                    'Total:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Rs. 600',
                    style: TextStyle(fontSize: 22),
                  ),
                ]
              )
            ),

            // CHECKOUT BUTTON
            InkWell(
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => Checkout(user: widget.user,),
                  ));
              },
              child: Container(
                height: 45,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Center(
                  child: Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      wordSpacing: 2.0,
                      letterSpacing: 0.9,
                    ),
                  ),
                )
              ),
            ),
          ],
        )
      ),
    );
  }
}