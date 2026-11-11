Gem::Specification.new do |spec|
  spec.name = "krea2-reference-crop"
  spec.version = "0.1.0"
  spec.summary = "Plan pixel-exact reference image crops"
  spec.description = "Calculate a crop rectangle that fits a target aspect ratio, with a focal point and a retained-area estimate."
  spec.authors = ["Krea2.io contributors"]
  spec.homepage = "https://krea2.io/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6"
  spec.files = %w[lib/krea2_reference_crop.rb exe/krea2-crop LICENSE README.md]
  spec.bindir = "exe"
  spec.executables = ["krea2-crop"]
  spec.require_paths = ["lib"]
  spec.metadata = {
    "source_code_uri" => "https://github.com/Ri-vai/krea2-reference-tools",
    "bug_tracker_uri" => "https://github.com/Ri-vai/krea2-reference-tools/issues"
  }
end
