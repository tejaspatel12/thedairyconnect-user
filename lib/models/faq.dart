import 'package:flutter/material.dart';
class FAQList {
  final String faq_id;
  final String faq_question;
  final String faq_answer;
  final String faq_status;


  FAQList({
    @required this.faq_id,
    @required this.faq_question,
    @required this.faq_answer,
    @required this.faq_status,
  });

  factory FAQList.fromJson(Map<String, dynamic> json) {
    return FAQList(
      faq_id: json['faq_id'],
      faq_question: json['faq_question'],
      faq_answer: json['faq_answer'],
      faq_status: json['faq_status'],
    );
  }
}
