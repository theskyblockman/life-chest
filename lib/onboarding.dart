import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:life_chest/main.dart';
import 'package:life_chest/new_chest.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<StatefulWidget> createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  late List<List<Widget>> welcomePages;

  PageController controller = PageController();
  int previousPage = 0;

  @override
  Widget build(BuildContext context) {
    AppLocalizations currentLocal = AppLocalizations.of(context)!;

    welcomePages = [
      [
        Text(currentLocal.welcomePage1Title,
            style: const TextStyle(fontWeight: FontWeight.w900),
            textScaleFactor: 3,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        Text(currentLocal.welcomePage1Content,
            style: const TextStyle(fontWeight: FontWeight.w600),
            textScaleFactor: 1.5,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade)
      ],
      [
        Text(currentLocal.welcomePage2Title,
            style: const TextStyle(fontWeight: FontWeight.w900),
            textScaleFactor: 1.75,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        Text(currentLocal.welcomePage2Content,
            style: const TextStyle(fontWeight: FontWeight.w600),
            textScaleFactor: 1.5,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade)
      ],
      [
        Text(currentLocal.welcomePage3Title,
            style: const TextStyle(fontWeight: FontWeight.w900),
            textScaleFactor: 2.25,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        Text(
          currentLocal.welcomePage3Content,
          style: const TextStyle(fontWeight: FontWeight.w600),
          textScaleFactor: 1.5,
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
        )
      ]
    ];

    bool isLastPage = controller.hasClients
        ? (controller.page!.round() == welcomePages.length - 1 ? true : false)
        : false;
    String textToDisplay =
    isLastPage ? currentLocal.createANewChest : currentLocal.welcomeNext;
    controller.addListener(
          () {
        int currentPage = controller.page!.round();
        if (previousPage != currentPage) {
          previousPage = currentPage;
          setState(() {});
        }
      },
    );
    return Scaffold(
      appBar: AppBar(actions: [
        AnimatedOpacity(
            opacity: isLastPage ? 0 : 1,
            duration: const Duration(milliseconds: 500),
            child: FilledButton.tonalIcon(
                onPressed: () {
                  if (!isLastPage) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChestMainPage()));
                  }
                },
                icon: const Icon(Icons.keyboard_double_arrow_right),
                label: Text(currentLocal.welcomeSkip)))
      ]),
      body: Center(
        child: Stack(children: [
          PageView.builder(
              itemBuilder: (context, index) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: welcomePages[index]);
              },
              scrollDirection: Axis.horizontal,
              controller: controller,
              itemCount: welcomePages.length),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: ElevatedButton.icon(
                      icon: isLastPage
                          ? const Icon(Icons.add)
                          : const Icon(Icons.chevron_right_rounded),
                      onPressed: () {
                        if (isLastPage) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChestMainPage(key: ChestMainPage.pageKey,)));
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const CreateNewChestPage())).then((value) => ChestMainPage.pageKey.currentState!.setState(() {}));
                        } else {
                          setState(() {
                            controller.nextPage(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut);
                          });
                        }
                      },
                      label: Text(textToDisplay),
                      key: ValueKey(textToDisplay),
                    ))),
          )
        ]),
      ),
      extendBodyBehindAppBar: true,
    );
  }
}