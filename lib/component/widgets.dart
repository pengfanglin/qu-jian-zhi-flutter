import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImgCache extends StatelessWidget {
  final imageUrl;
  final placeholder;
  final errorWidget;

  ImgCache(this.imageUrl, {this.placeholder, this.errorWidget});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => placeholder == null ? Image.asset('res/images/loading.gif',fit: BoxFit.fill) : placeholder,
      errorWidget: (context, url, error) => errorWidget == null ? Image.asset('res/images/404.png', fit: BoxFit.fill) : errorWidget,
      fit: BoxFit.fill,
    );
  }
}
