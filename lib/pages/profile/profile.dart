import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconly/iconly.dart';
import 'package:login/shared/constants/custom_colors.dart';
import 'package:login/widgets/custom_list_tile.dart';

class Profile extends StatelessWidget {
  final String name;
  final String email;

  const Profile({Key? key, required this.name, required this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors().gradienteMainColor,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Stack(
            children: [
              Container(
                height: 250,
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 230,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Gap(60),
                      Center(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Gap(10),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const Gap(25),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Gap(35),
          CustomListTile(
            icon: IconlyBold.profile,
            color: const Color(0xFFC76CD9),
            title: 'Informações',
            context: context,
          ),
          CustomListTile(
            icon: IconlyBold.message,
            color: const Color(0xFFe17a0a),
            title: 'Contate-nos',
            context: context,
          ),
          CustomListTile(
            icon: IconlyBold.document,
            color: const Color(0xFF064c6d),
            title: 'Suporte',
            context: context,
          ),
          CustomListTile(
            icon: IconlyBold.logout,
            color: const Color(0xFF229e76),
            title: 'Logout',
            context: context,
          ),
        ],
      ),
    );
  }
}
