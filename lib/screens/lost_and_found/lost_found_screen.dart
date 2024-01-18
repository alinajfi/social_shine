import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lost_found/constant.dart';
import 'package:lost_found/models/item_model.dart';
import 'package:lost_found/screens/admin/upload_item_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({Key? key}) : super(key: key);

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  Future<void> updateItemStatus(String itemId, String newItemStatus) async {
    try {
      final itemRef = FirebaseFirestore.instance
          .collection('lost_and_found_items')
          .doc(itemId);

      // Update the itemStatus field with the new value.
      await itemRef.update({'itemStatus': newItemStatus});
    } catch (e) {
      if (kDebugMode) {
        print('Error updating item status: $e');
      }
      // Handle the error as needed.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lost And Found',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          if (FirebaseAuth.instance.currentUser!.email == adminEmail)
            IconButton(
              icon: const Icon(Icons.upload),
              onPressed: () {
                // Handle search button click
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const UploadItemScreen()));
              },
            ),
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('lost_and_found_items')
              .orderBy("time", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                  child:
                      CircularProgressIndicator()); // Loading indicator while data is being fetched.
            }
            return GridView.builder(
                itemCount: snapshot.data!.docs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) {
                  var item = snapshot.data!.docs[index];
                  var data =
                      ItemModel.fromJson(snapshot.data!.docs[index].data());
                  return Card(
                    key: UniqueKey(),
                    child: SizedBox(
                        // height: 180,
                        child: Column(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              log(data.imageUrl);

                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                height: 300,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20),
                                                          topRight:
                                                              Radius.circular(
                                                                  20)),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        data.imageUrl),
                                                    // Replace 'e' with your image URL
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 10.0,
                                                // Adjust the top position as needed
                                                right: 10.0,
                                                // Adjust the right position as needed
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context); // Close the dialog
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const Text("Name:",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 22,
                                                    )),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  data.name,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const Text("Status:",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 22,
                                                    )),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  data.itemStatus,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text("Details:",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 22,
                                                    )),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    data.location,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 20),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: CachedNetworkImage(
                              imageUrl: data.imageUrl,
                              // width: 50,
                              // height: 80,
                            ),
                          ),
                        ),
                        Text(
                          data.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text(
                        //       data.name,
                        //       style: const TextStyle(
                        //           fontWeight: FontWeight.bold, fontSize: 20),
                        //     ),
                        //     // const Icon(
                        //     //   Icons.favorite_border,
                        //     //   color: Colors.red,
                        //     // ),
                        //   ],
                        // ),
                        Row(
                          children: [
                            const Icon(Icons.location_on),
                            Expanded(
                              child: Text(
                                data.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Color(0xFFCEC3FF),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 2),
                                  child: Text(data.itemStatus),
                                ),
                              ),
                            ),
                            if (FirebaseAuth.instance.currentUser!.email ==
                                adminEmail) ...[
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    updateItemStatus(
                                        snapshot.data!.docs[index].id,
                                        data.itemStatus == "Found"
                                            ? "Lost"
                                            : "Found");
                                  },
                                  icon: Icon(data.itemStatus != "Found"
                                      ? Icons.check
                                      : Icons.close)),
                              IconButton(
                                  onPressed: () {
                                    deleteItem(item.id);
                                  },
                                  icon: const Icon(Icons.delete))
                            ]
                          ],
                        ),
                        Text(timeago.format(data.time, locale: 'en'))
                      ],
                    )),
                  );
                });
          }),
      // SingleChildScrollView(
      //     child: Column(
      //   children: [
      //     const Align(
      //       alignment: Alignment.centerLeft,
      //       child: Text(
      //         '   Items',
      //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      //       ),
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.all(10),
      //       child: Row(
      //         children: [
      //           Container(
      //             width: MediaQuery.of(context).size.width * .45,
      //             color: const Color(0xFFf1f1f1),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Image(
      //                   image: const AssetImage('assets/mobile.jpg'),
      //                   height: 100,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Text(' Mobile Phone  '),
      //                     Icon(
      //                       Icons.favorite_border,
      //                       color: Colors.red,
      //                     ),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Icon(Icons.location_on),
      //                     Text('  AI University'),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.only(left: 8),
      //                   child: Container(
      //                     decoration: const BoxDecoration(
      //                         color: Colors.grey,
      //                         borderRadius:
      //                             BorderRadius.all(Radius.circular(5))),
      //                     child: const Text(' Lost '),
      //                   ),
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Text('  2 Hours Ago'),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Container(
      //                   height: 30,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                   decoration: const BoxDecoration(
      //                     borderRadius: BorderRadius.only(
      //                         bottomLeft: Radius.circular(10),
      //                         bottomRight: Radius.circular(10)),
      //                     gradient: LinearGradient(
      //                       begin: Alignment.topLeft,
      //                       end: Alignment.bottomRight,
      //                       colors: [
      //                         Color(0xFFCEC3FF),
      //                         Color(0xFFCEC3FF)
      //                       ], // Two colors for the gradient
      //                     ),
      //                   ),
      //                   child: MaterialButton(
      //                     elevation: 3.0,
      //                     shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(10),
      //                     ),
      //                     onPressed: () {
      //                       Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                               builder: (context) => ItemDetailsScreen(
      //                                     title: 'Mobile Phone',
      //                                     image: 'assets/mobile.jpg',
      //                                     address: 'AI University',
      //                                   )));
      //                     },
      //                     child: const Text(
      //                       'Found',
      //                       style: TextStyle(color: Colors.white),
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //           SizedBox(
      //             width: MediaQuery.of(context).size.width * .03,
      //           ),
      //           Container(
      //             width: MediaQuery.of(context).size.width * .45,
      //             color: const Color(0xFFf1f1f1),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Image(
      //                   image: const AssetImage('assets/key.png'),
      //                   height: 100,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Text('  Car Keys  '),
      //                     Icon(
      //                       Icons.favorite_border,
      //                       color: Colors.red,
      //                     ),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Icon(Icons.location_on),
      //                     Text('  AI Corridor'),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.only(left: 8),
      //                   child: Container(
      //                     decoration: const BoxDecoration(
      //                         color: Colors.grey,
      //                         borderRadius:
      //                             BorderRadius.all(Radius.circular(5))),
      //                     child: const Text(' Lost '),
      //                   ),
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Text('  6 Hours Ago'),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Container(
      //                   height: 30,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                   decoration: const BoxDecoration(
      //                     borderRadius: BorderRadius.only(
      //                         bottomLeft: Radius.circular(10),
      //                         bottomRight: Radius.circular(10)),
      //                     gradient: LinearGradient(
      //                       begin: Alignment.topLeft,
      //                       end: Alignment.bottomRight,
      //                       colors: [
      //                         Color(0xFFCEC3FF),
      //                         Color(0xFFCEC3FF)
      //                       ], // Two colors for the gradient
      //                     ),
      //                   ),
      //                   child: MaterialButton(
      //                     elevation: 3.0,
      //                     shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(10),
      //                     ),
      //                     onPressed: () {
      //                       Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                               builder: (context) => ItemDetailsScreen(
      //                                     title: 'Car Key',
      //                                     image: 'assets/key.png',
      //                                     address: 'AI Corridor',
      //                                   )));
      //                     },
      //                     child: const Text(
      //                       'Found',
      //                       style: TextStyle(color: Colors.white),
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.all(10),
      //       child: Row(
      //         children: [
      //           Container(
      //             width: MediaQuery.of(context).size.width * .45,
      //             color: const Color(0xFFf1f1f1),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Image(
      //                   image: const AssetImage('assets/airPods.jpg'),
      //                   height: 100,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Text('  Ear Pods  '),
      //                     Icon(
      //                       Icons.favorite_border,
      //                       color: Colors.red,
      //                     ),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Icon(Icons.location_on),
      //                     Text('  Main Road Uni'),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.only(left: 8),
      //                   child: Container(
      //                     decoration: const BoxDecoration(
      //                         color: Colors.grey,
      //                         borderRadius:
      //                             BorderRadius.all(Radius.circular(5))),
      //                     child: const Text(' Lost '),
      //                   ),
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Text('  3 Hours Ago'),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Container(
      //                   height: 30,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                   decoration: const BoxDecoration(
      //                     borderRadius: BorderRadius.only(
      //                         bottomLeft: Radius.circular(10),
      //                         bottomRight: Radius.circular(10)),
      //                     gradient: LinearGradient(
      //                       begin: Alignment.topLeft,
      //                       end: Alignment.bottomRight,
      //                       colors: [
      //                         Color(0xFFCEC3FF),
      //                         Color(0xFFCEC3FF)
      //                       ], // Two colors for the gradient
      //                     ),
      //                   ),
      //                   child: MaterialButton(
      //                     elevation: 3.0,
      //                     shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(10),
      //                     ),
      //                     onPressed: () {
      //                       Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                               builder: (context) => ItemDetailsScreen(
      //                                     title: 'Ear Pods',
      //                                     image: 'assets/airPods.jpg',
      //                                     address: 'Main Road Uni',
      //                                   )));
      //                     },
      //                     child: const Text(
      //                       'Found',
      //                       style: TextStyle(color: Colors.white),
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //           SizedBox(
      //             width: MediaQuery.of(context).size.width * .03,
      //           ),
      //           Container(
      //             width: MediaQuery.of(context).size.width * .45,
      //             color: const Color(0xFFf1f1f1),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Image(
      //                   image: const AssetImage('assets/cap.jpg'),
      //                   height: 100,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Text('  Wearing Cap  '),
      //                     Icon(
      //                       Icons.favorite_border,
      //                       color: Colors.red,
      //                     ),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Icon(Icons.location_on),
      //                     Text('  AI University'),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.only(left: 8),
      //                   child: Container(
      //                     decoration: const BoxDecoration(
      //                         color: Colors.grey,
      //                         borderRadius:
      //                             BorderRadius.all(Radius.circular(5))),
      //                     child: const Text(' Found '),
      //                   ),
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Text('  1 Hours Ago'),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Container(
      //                   height: 30,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                   decoration: const BoxDecoration(
      //                     borderRadius: BorderRadius.only(
      //                         bottomLeft: Radius.circular(10),
      //                         bottomRight: Radius.circular(10)),
      //                     gradient: LinearGradient(
      //                       begin: Alignment.topLeft,
      //                       end: Alignment.bottomRight,
      //                       colors: [
      //                         Color(0xFFCEC3FF),
      //                         Color(0xFFCEC3FF)
      //                       ], // Two colors for the gradient
      //                     ),
      //                   ),
      //                   child: MaterialButton(
      //                     elevation: 3.0,
      //                     shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(10),
      //                     ),
      //                     onPressed: () {
      //                       Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                               builder: (context) => ItemDetailsScreen(
      //                                     title: 'Wearing Cap',
      //                                     image: 'assets/cap.jpg',
      //                                     address: 'AI University',
      //                                   )));
      //                     },
      //                     child: const Text(
      //                       'Found',
      //                       style: TextStyle(color: Colors.white),
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.all(10),
      //       child: Row(
      //         children: [
      //           Container(
      //             width: MediaQuery.of(context).size.width * .45,
      //             color: const Color(0xFFf1f1f1),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Image(
      //                   image: const AssetImage('assets/sunGlasses.jpg'),
      //                   height: 100,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Text('  Sun Glasses  '),
      //                     Icon(
      //                       Icons.favorite_border,
      //                       color: Colors.red,
      //                     ),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Icon(Icons.location_on),
      //                     Text('  Link Road'),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.only(left: 8),
      //                   child: Container(
      //                     decoration: const BoxDecoration(
      //                         color: Colors.grey,
      //                         borderRadius:
      //                             BorderRadius.all(Radius.circular(5))),
      //                     child: const Text(' Lost '),
      //                   ),
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Text('  2 Hours Ago'),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Container(
      //                   height: 30,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                   decoration: const BoxDecoration(
      //                     borderRadius: BorderRadius.only(
      //                         bottomLeft: Radius.circular(10),
      //                         bottomRight: Radius.circular(10)),
      //                     gradient: LinearGradient(
      //                       begin: Alignment.topLeft,
      //                       end: Alignment.bottomRight,
      //                       colors: [
      //                         Color(0xFFCEC3FF),
      //                         Color(0xFFCEC3FF)
      //                       ], // Two colors for the gradient
      //                     ),
      //                   ),
      //                   child: MaterialButton(
      //                     elevation: 3.0,
      //                     shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(10),
      //                     ),
      //                     onPressed: () {
      //                       Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                               builder: (context) => ItemDetailsScreen(
      //                                     title: 'Sun Glasses',
      //                                     image: 'assets/sunGlasses.jpg',
      //                                     address: 'Link Road',
      //                                   )));
      //                     },
      //                     child: const Text(
      //                       'Found',
      //                       style: TextStyle(color: Colors.white),
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //           SizedBox(
      //             width: MediaQuery.of(context).size.width * .03,
      //           ),
      //           Container(
      //             width: MediaQuery.of(context).size.width * .45,
      //             color: const Color(0xFFf1f1f1),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Image(
      //                   image: const AssetImage('assets/watrch.jpg'),
      //                   height: 100,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Text('  Wrist Watch  '),
      //                     Icon(
      //                       Icons.favorite_border,
      //                       color: Colors.red,
      //                     ),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Icon(Icons.location_on),
      //                     Text('  AI University'),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.only(left: 8),
      //                   child: Container(
      //                     decoration: const BoxDecoration(
      //                         color: Colors.grey,
      //                         borderRadius:
      //                             BorderRadius.all(Radius.circular(5))),
      //                     child: const Text(' Lost '),
      //                   ),
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Text('  2 Hours Ago'),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Container(
      //                   height: 30,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                   decoration: const BoxDecoration(
      //                     borderRadius: BorderRadius.only(
      //                         bottomLeft: Radius.circular(10),
      //                         bottomRight: Radius.circular(10)),
      //                     gradient: LinearGradient(
      //                       begin: Alignment.topLeft,
      //                       end: Alignment.bottomRight,
      //                       colors: [
      //                         Color(0xFFCEC3FF),
      //                         Color(0xFFCEC3FF)
      //                       ], // Two colors for the gradient
      //                     ),
      //                   ),
      //                   child: MaterialButton(
      //                     elevation: 3.0,
      //                     shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(10),
      //                     ),
      //                     onPressed: () {
      //                       Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                               builder: (context) => ItemDetailsScreen(
      //                                     title: 'Wrist Watch',
      //                                     image: 'assets/watrch.jpg',
      //                                     address: 'AI University',
      //                                   )));
      //                     },
      //                     child: const Text(
      //                       'Found',
      //                       style: TextStyle(color: Colors.white),
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.all(10),
      //       child: Row(
      //         children: [
      //           Container(
      //             width: MediaQuery.of(context).size.width * .45,
      //             color: const Color(0xFFf1f1f1),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Image(
      //                   image: const AssetImage('assets/bottle.jpg'),
      //                   height: 100,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Text('  Water Bottle  '),
      //                     Icon(
      //                       Icons.favorite_border,
      //                       color: Colors.red,
      //                     ),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Icon(Icons.location_on),
      //                     Text('  Campus Road'),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.only(left: 8),
      //                   child: Container(
      //                     decoration: const BoxDecoration(
      //                         color: Colors.grey,
      //                         borderRadius:
      //                             BorderRadius.all(Radius.circular(5))),
      //                     child: const Text(' Found '),
      //                   ),
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Text('  4 Hours Ago'),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Container(
      //                   height: 30,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                   decoration: const BoxDecoration(
      //                     borderRadius: BorderRadius.only(
      //                         bottomLeft: Radius.circular(10),
      //                         bottomRight: Radius.circular(10)),
      //                     gradient: LinearGradient(
      //                       begin: Alignment.topLeft,
      //                       end: Alignment.bottomRight,
      //                       colors: [
      //                         Color(0xFFCEC3FF),
      //                         Color(0xFFCEC3FF)
      //                       ], // Two colors for the gradient
      //                     ),
      //                   ),
      //                   child: MaterialButton(
      //                     elevation: 3.0,
      //                     shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(10),
      //                     ),
      //                     onPressed: () {
      //                       Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                               builder: (context) => ItemDetailsScreen(
      //                                     title: 'Water Bottle',
      //                                     image: 'assets/bottle.jpg',
      //                                     address: 'Campus Road',
      //                                   )));
      //                     },
      //                     child: const Text(
      //                       'Found',
      //                       style: TextStyle(color: Colors.white),
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //           SizedBox(
      //             width: MediaQuery.of(context).size.width * .03,
      //           ),
      //           Container(
      //             width: MediaQuery.of(context).size.width * .45,
      //             color: const Color(0xFFf1f1f1),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Image(
      //                   image: const AssetImage('assets/mobile.jpg'),
      //                   height: 100,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Text('  Mobile Phone  '),
      //                     Icon(
      //                       Icons.favorite_border,
      //                       color: Colors.red,
      //                     ),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Row(
      //                   children: [
      //                     Icon(Icons.location_on),
      //                     Text('  AI University'),
      //                   ],
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.only(left: 8),
      //                   child: Container(
      //                     decoration: const BoxDecoration(
      //                         color: Colors.grey,
      //                         borderRadius:
      //                             BorderRadius.all(Radius.circular(5))),
      //                     child: const Text(' Lost '),
      //                   ),
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 const Text('  2 Hours Ago'),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Container(
      //                   height: 30,
      //                   width: MediaQuery.of(context).size.width * 1,
      //                   decoration: const BoxDecoration(
      //                     borderRadius: BorderRadius.only(
      //                         bottomLeft: Radius.circular(10),
      //                         bottomRight: Radius.circular(10)),
      //                     gradient: LinearGradient(
      //                       begin: Alignment.topLeft,
      //                       end: Alignment.bottomRight,
      //                       colors: [
      //                         Color(0xFFCEC3FF),
      //                         Color(0xFFCEC3FF)
      //                       ], // Two colors for the gradient
      //                     ),
      //                   ),
      //                   child: MaterialButton(
      //                     elevation: 3.0,
      //                     shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(10),
      //                     ),
      //                     onPressed: () {
      //                       Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                               builder: (context) => ItemDetailsScreen(
      //                                     title: 'Mobile Phone',
      //                                     image: 'assets/mobile.jpg',
      //                                     address: 'AI University',
      //                                   )));
      //                     },
      //                     child: const Text(
      //                       'Found',
      //                       style: TextStyle(color: Colors.white),
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // )),
    );
  }

  deleteItem(documentId) {
    FirebaseFirestore.instance
        .collection('lost_and_found_items')
        .doc(documentId)
        .delete()
        .then((value) {
      Fluttertoast.showToast(msg: "Item deleted sucessfullly");
    }).catchError((error) {
      print('Error deleting document: $error');
    });
  }
}

class MyContainer extends StatelessWidget {
  const MyContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Image.asset(
            'assets/social.png', // Replace with your image URL
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          ),
          const Row(
            children: [
              Icon(Icons.favorite_border),
              Text('Title'),
            ],
          ),
          const Row(
            children: [
              Icon(Icons.location_on),
              Text('Location'),
            ],
          ),
          const Text('Address'),
          const Text('Some Text'),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCEC3FF), // Button color
            ),
            child: const Text('Button'),
          ),
        ],
      ),
    );
  }
}
