class VenueDto {
  final String name;
  final String imageUrl;

  VenueDto.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        imageUrl = map['imageUrl'];
}
