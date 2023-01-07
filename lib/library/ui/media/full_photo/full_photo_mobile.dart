import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/photo.dart';
import '../../../functions.dart';

class FullPhotoMobile extends StatefulWidget {
  final Photo photo;

  const FullPhotoMobile({super.key, required this.photo});


  @override
  FullPhotoMobileState createState() => FullPhotoMobileState();
}

class FullPhotoMobileState extends State<FullPhotoMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.photo.projectName}',
            style: GoogleFonts.lato(
              textStyle: Theme.of(context).textTheme.bodySmall,
              fontWeight: FontWeight.w900,),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(28),
            child: Column(
              children: [
                Text(
                  getFormattedDateLongWithTime(widget.photo.created!, context),
                  style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.bodySmall,
                    fontWeight: FontWeight.normal,),
                ),
                const SizedBox(
                  height: 16,
                )
              ],
            ),
          ),
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.photo.url!,
              fit: BoxFit.fill,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Center(
                      child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              value: downloadProgress.progress))),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Positioned(
              right: 20,
              bottom: 2,
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, bottom: 8, top: 8),
                  child: Row(
                    children: [
                       Text('Distance from Project', style: GoogleFonts.lato(
                        textStyle: Theme.of(context).textTheme.bodySmall,
                        fontWeight: FontWeight.normal,),),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        widget.photo.distanceFromProjectPosition!
                            .toStringAsFixed(1),
                        style: GoogleFonts.lato(
                          textStyle: Theme.of(context).textTheme.bodySmall,
                          fontWeight: FontWeight.w900,),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                       Text('metres', style: GoogleFonts.lato(
                        textStyle: Theme.of(context).textTheme.bodySmall,
                        fontWeight: FontWeight.normal,),),
                      const SizedBox(
                        width: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
