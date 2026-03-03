// import 'package:hive/hive.dart';
// import 'package:uuid/uuid.dart';
// import 'package:daisy_brew/features/dashboard/domain/entities/product_entity.dart';
// import 'package:daisy_brew/core/constants/hive_table_constants.dart';

// part 'tea_hive_model.g.dart';

// @HiveType(typeId: HiveTableConstant.teaProductTypeId)
// class TeaHiveModel extends HiveObject {
//   @HiveField(0)
//   final String id;

//   @HiveField(1)
//   final String name;

//   @HiveField(2)
//   final String? image;

//   @HiveField(3)
//   final int price;

//   @HiveField(4)
//   final bool isAvailable;

//   @HiveField(5)
//   final String category;

//   TeaHiveModel({
//     String? id,
//     required this.name,
//     this.image,
//     required this.price,
//     required this.isAvailable,
//     this.category = 'Tea',
//   }) : id = id ?? const Uuid().v4();

//   Product toEntity() => Product(
//     id: id,
//     name: name,
//     image: image != null && !image!.startsWith('http')
//         ? 'http://192.168.254.50:3000/public/product_images/$image'
//         : (image ?? ''),
//     price: price,
//     isAvailable: isAvailable,
//     category: category,
//   );

//   factory TeaHiveModel.fromEntity(Product entity) {
//     return TeaHiveModel(
//       id: entity.id,
//       name: entity.name,
//       image: entity.image,
//       price: entity.price,
//       isAvailable: entity.isAvailable,
//       category: entity.category,
//     );
//   }
// }
