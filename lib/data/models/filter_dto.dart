import 'package:vikunja_app/data/models/dto.dart';
import 'package:vikunja_app/domain/entities/filter.dart';

class FilterDto extends Dto<Filter> {
  final String s;
  List<String>? sortBy;
  List<String>? orderBy;
  String filter;
  bool filterIncludesNulls;

  FilterDto(
    this.s,
    this.sortBy,
    this.orderBy,
    this.filter,
    this.filterIncludesNulls,
  );

  // Null-tolerant, damit rawJson aus toJSON (das die Server-Keys nicht 1:1
  // schreibt) verlustfrei zurückgelesen werden kann.
  FilterDto.fromJson(Map<String, dynamic> json)
    : s = json['s'] ?? '',
      sortBy = (json['sort_by'] ?? json['sortBy']) == null
          ? []
          : ((json['sort_by'] ?? json['sortBy']) as List<dynamic>)
                .map((e) => e.toString())
                .toList(),
      orderBy = (json['order_by'] ?? json['orderBy']) == null
          ? []
          : ((json['order_by'] ?? json['orderBy']) as List<dynamic>)
                .map((e) => e.toString())
                .toList(),
      filter = json['filter'] ?? '',
      filterIncludesNulls =
          json['filter_include_nulls'] ?? json['filterIncludesNulls'] ?? false;

  Map<String, dynamic> toJSON() => {
    's': s,
    'sortBy': sortBy,
    'orderBy': orderBy,
    'filter': filter,
    'filterIncludesNulls': filterIncludesNulls,
  };

  @override
  Filter toDomain() => Filter(s, sortBy, orderBy, filter, filterIncludesNulls);

  static FilterDto fromDomain(Filter p) =>
      FilterDto(p.s, p.sortBy, p.orderBy, p.filter, p.filterIncludesNulls);
}
