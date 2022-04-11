import 'package:flutter/material.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:provider/provider.dart';

class NumbersWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<AppContext>(builder: (context, s, _){
    String winRatio = '${s.userProps["winGames"] ?? "0"} / ${s.userProps["playedGames"] ?? "0"}';
    String qRatio = '${s.userProps["correctQ"] ?? "0"} / ${s.userProps["totalQ"] ?? "0"}';
    String aRatio = '${s.userProps["correctA"] ?? "0"} / ${s.userProps["totalA"] ?? "0"}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        buildButton(context, winRatio, ' Oyun Kazandın'),
        buildDivider(),
        buildButton(context, qRatio, 'İsabetli Soru'),
        buildDivider(),
        buildButton(context, aRatio, 'Doğru Tahmin'),
      ],
  );},
  );
  Widget buildDivider() => Container(
    height: 24,
    child: VerticalDivider(),
  );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}