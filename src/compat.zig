//! Zig 0.17 compatibility for comptime reflection.
//!
//! Zig 0.17 replaced the `fields` slice of struct and union type info with
//! parallel `field_names` / `field_types` / `field_attrs` slices. These helpers
//! rebuild the former view (name, type, default value) so the decoder and
//! encoder can keep iterating `fields`.

pub const Field = struct {
    name: [:0]const u8,
    type: type,
    default_value_ptr: ?*const anyopaque = null,

    pub fn defaultValue(comptime f: Field) ?f.type {
        const dp: *const f.type = @ptrCast(@alignCast(f.default_value_ptr orelse return null));
        return dp.*;
    }
};

pub const Info = struct { fields: []const Field };

pub fn structInfo(comptime T: type) Info {
    const s = @typeInfo(T).@"struct";
    comptime var out: [s.field_names.len]Field = undefined;
    inline for (0..s.field_names.len) |i| {
        out[i] = .{
            .name = s.field_names[i],
            .type = s.field_types[i],
            .default_value_ptr = s.field_attrs[i].default_value_ptr,
        };
    }
    const final = out;
    return .{ .fields = &final };
}

pub fn unionInfo(comptime T: type) Info {
    const u = @typeInfo(T).@"union";
    comptime var out: [u.field_names.len]Field = undefined;
    inline for (0..u.field_names.len) |i| {
        out[i] = .{ .name = u.field_names[i], .type = u.field_types[i] };
    }
    const final = out;
    return .{ .fields = &final };
}
