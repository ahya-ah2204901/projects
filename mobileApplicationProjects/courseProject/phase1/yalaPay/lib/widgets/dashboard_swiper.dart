import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:yala_pay/models/color_constants.dart';

class SwiperBuilder extends StatefulWidget {
  const SwiperBuilder({
    super.key,
  });

  @override
  State<SwiperBuilder> createState() => _SwiperBuilderState();
}

class _SwiperBuilderState extends State<SwiperBuilder> {
  @override
  Widget build(BuildContext context) {
    var cards = summaryCards();
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Swiper(
              itemWidth: 400,
              itemHeight: 200,
              loop: true,
              duration: 1200,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                // Swiper Using Images

                // var imagepath = [
                //   'assets/images/dashboard_cards/Invoice_card.png',
                //   'assets/images/dashboard_cards/Cheque_card.png'
                // ];

                return Container(
                  width: 400,
                  height: 220,
                  decoration: const BoxDecoration(
                    // Swiper Using Images

                    // image: DecorationImage(
                    //   image: AssetImage(imagepath[index]),
                    //   fit: BoxFit.cover,
                    // ),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: cards[index],
                );
              },
              itemCount: cards.length,
              layout: SwiperLayout.STACK,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> summaryCards() {
    List<Widget> cards = [];
    var titleTextStyle1 = TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.w700,
        fontSize: 16,
        letterSpacing: 0.2);
    var titleTextStyle2 = TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.w700,
        fontSize: 16,
        letterSpacing: 0.2);
    var subtitleTextStyle1 = TextStyle(
      color: primaryColor,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    );
    var subtitleTextStyle2 = TextStyle(
      color: primaryColor,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    );

    cards.add(Card(
      color: secondaryColor,
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('INVOICE SUMMARY', style: titleTextStyle2),
            const Spacer(),
            Row(
              children: [
                Text(
                  'Overall Invoices Due\nDue in 30 days\nDue in 60 days',
                  style: subtitleTextStyle2,
                ),
                const Spacer(),
                Text(
                  '99.99  QAR\n33.33  QAR\n66.66  QAR',
                  style: subtitleTextStyle2,
                  textAlign: TextAlign.end,
                )
              ],
            ),
          ],
        ),
      ),
    ));

    cards.add(Card(
      color: blankColor,
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CHEQUE SUMMARY',
              style: titleTextStyle1,
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  'Awaiting\nDeposited\nCashed\nReturned',
                  style: subtitleTextStyle1,
                ),
                const Spacer(),
                Text(
                  '99.99  QAR\n33.33  QAR\n55.55  QAR\n11.11  QAR',
                  style: subtitleTextStyle1,
                  textAlign: TextAlign.end,
                )
              ],
            ),
          ],
        ),
      ),
    ));

    return cards;
  }
}
