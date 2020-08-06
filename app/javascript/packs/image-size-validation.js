$(function() {
  $("#micropost_image").bind("change", function() {
    var size_in_megabytes = this.files[0].size / 1024 / 1024;
    if (size_in_megabytes > image_maxsize) {
      alert(I18n.t("microposts.alert.image_size", {size: image_maxsize}));
    }
  });
});
