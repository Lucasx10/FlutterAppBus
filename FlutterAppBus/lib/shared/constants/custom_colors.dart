import "package:flutter/material.dart";

class CustomColors {
  Color activePrimaryButton = Color.fromARGB(255, 63, 81, 181);
  Color activeSecondaryButton = Color.fromARGB(255, 230, 230, 255);

  Color gradienteMainColor = Color.fromARGB(255, 0, 110, 253);
  Color gradientSecColor = Color.fromARGB(255, 79, 155, 255);

  Color getActivePrimaryButtonColor() {
    return activePrimaryButton;
  }

  Color getActiveSecondaryButtonColor() {
    return activeSecondaryButton;
  }

  Color getGradienteMainColor() {
    return gradienteMainColor;
  }

  Color getGradienteSecColor() {
    return gradientSecColor;
  }
}
