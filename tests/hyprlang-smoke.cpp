// Validate syntax and basic property types using the native Hyprlang parser.
// Layout/gradient custom values are strings here; this is not GPU/PAM validation.
#include <hyprlang.hpp>
#include <iostream>
int main(int argc, char** argv) {
    if (argc != 2) return 2;
    Hyprlang::CConfig cfg(argv[1], {.throwAllErrors = true});
    cfg.addConfigValue("general:hide_cursor", Hyprlang::INT{0});
    auto category = [&](const char* name) { cfg.addSpecialCategory(name, {.key = nullptr, .anonymousKeyBased = true}); };
    auto strings = [&](const char* cat, std::initializer_list<const char*> keys) { for (auto key : keys) cfg.addSpecialConfigValue(cat,key,Hyprlang::STRING{""}); };
    auto ints = [&](const char* cat, std::initializer_list<const char*> keys) { for (auto key : keys) cfg.addSpecialConfigValue(cat,key,Hyprlang::INT{0}); };
    category("background"); strings("background",{"monitor","path"}); ints("background",{"blur_passes"}); cfg.addSpecialConfigValue("background","brightness",Hyprlang::FLOAT{1.0});
    category("shape"); strings("shape",{"monitor","size","color","border_color","position","halign","valign"}); ints("shape",{"rounding","border_size","zindex"});
    category("label"); strings("label",{"monitor","text","color","font_family","position","halign","valign"}); ints("label",{"font_size","zindex"});
    category("input-field"); strings("input-field",{"monitor","size","outer_color","inner_color","font_color","check_color","fail_color","placeholder_text","fail_text","position","halign","valign"}); ints("input-field",{"outline_thickness","dots_center","rounding","zindex"});cfg.addSpecialConfigValue("input-field","dots_size",Hyprlang::FLOAT{0.25});
    cfg.commence(); auto result=cfg.parse();
    if (result.error) { std::cerr << result.getError() << '\n'; return 1; }
    std::cout << "Native Hyprlang syntax/basic-property smoke test passed (not GPU/PAM).\n";
}
