import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:oidc4vc/oidc4vc.dart';

part 'credential_subject_type_extension.dart';

enum CredentialSubjectType {
  ageRange,
  aragoEmailPass,
  aragoIdentityCard,
  aragoLearningAchievement,
  aragoOver18,
  aragoPass,
  binanceAssociatedWallet,
  binancePooAddress,
  livenessCard,
  certificateOfEmployment,
  chainbornMembership,
  defaultCredential,
  defiCompliance,
  diplomaCard,
  emailPass,
  ethereumAssociatedWallet,
  ethereumPooAddress,
  euDiplomaCard,
  euVerifiableId,
  fantomAssociatedWallet,
  fantomPooAddress,
  gender,
  identityPass,
  kycAgeCredential,
  kycCountryOfResidence,
  learningAchievement,
  linkedInCard,
  nationality,
  over13,
  over15,
  over18,
  over21,
  over50,
  over65,
  passportFootprint,
  pcdsAgentCertificate,
  phonePass,
  polygonAssociatedWallet,
  polygonPooAddress,
  professionalExperienceAssessment,
  professionalSkillAssessment,
  professionalStudentCard,
  residentCard,
  selfIssued,
  studentCard,
  tezosAssociatedWallet,
  tezosPooAddress,
  tezotopiaMembership,
  tezVoucher,
  twitterCard,
  verifiableIdCard,
  voucher,
  walletCredential,
  proofOfTwitterStats,
  civicPassCredential,
  employeeCredential,
  legalPersonalCredential,
  identityCredential,
  eudiPid,
  pid,
}
