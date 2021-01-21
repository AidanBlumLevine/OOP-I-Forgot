import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final double opacity;
  final Widget child;
  final onDismissed;
  final String name;
  final bool dotIndicator, background, redIndicator;
  const ListCard({
    this.opacity = 1,
    this.child,
    this.name = "this item",
    this.onDismissed,
    this.dotIndicator = false,
    this.redIndicator = false,
    this.background = false,
    @required Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      key: key,
      background: Container(
          padding: EdgeInsets.fromLTRB(0, 8, 20, 0),
          child: new Align(
            alignment: Alignment.centerRight,
            child: Container(
              child: new Text('Delete', textAlign: TextAlign.right, style: new TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              padding: background ? EdgeInsets.symmetric(vertical: 8, horizontal: 8) : null,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: background ? Colors.white : Color(0x00FFFFFF),
              ),
            ),
          )),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm"),
              content: Text("Are you sure you want to delete $name ?"),
              actions: <Widget>[
                FlatButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Delete")),
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (_) {
        onDismissed();
      },
      child: Opacity(
        opacity: opacity,
        child: Stack(children: [
          Card(
            margin: EdgeInsets.fromLTRB(6, 6, 6, 0),
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.fromLTRB(6, 5, 6, 5),
              child: child,
            ),
          ),
          Positioned(
            right: 1,
            top: 1,
            child: dotIndicator || redIndicator
                ? Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: redIndicator ? Colors.red : Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(blurRadius: 2, color: Colors.blueAccent, offset: Offset(0, 1))],
                    ),
                  )
                : Container(),
          ),
        ]),
      ),
    );
  }
}
