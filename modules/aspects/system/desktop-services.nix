# Desktop integration services — flatpak, appimage, default apps.
{ lib, ... }:
let
  # Every listed MIME type opens with `app`.
  openWith = app: types: lib.genAttrs types (_: app);
in
{
  den.aspects.desktop-services = {
    nixos = {
      services.flatpak.enable = true;
      programs.appimage.enable = true;
      xdg.mime.defaultApplications = {
        # Directories
        "inode/directory" = "org.gnome.Nautilus.desktop";
        # PDF
        "application/pdf" = "okularApplication_pdf.desktop";
      }
      # Markdown
      // openWith "okularApplication_md.desktop" [
        "text/markdown"
        "text/x-markdown"
      ]
      # Writer — plain text, word docs
      // openWith "writer.desktop" [
        "text/plain"
        "text/rtf"
        "application/rtf"
        "application/msword"
        "application/vnd.ms-word"
        "application/vnd.ms-word.document.macroEnabled.12"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.template"
        "application/vnd.oasis.opendocument.text"
      ]
      # Calc — spreadsheets
      // openWith "calc.desktop" [
        "application/vnd.ms-excel"
        "application/vnd.ms-excel.sheet.macroEnabled.12"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.template"
        "application/vnd.oasis.opendocument.spreadsheet"
        "text/csv"
      ]
      # Impress — presentations
      // openWith "impress.desktop" [
        "application/mspowerpoint"
        "application/vnd.ms-powerpoint"
        "application/vnd.ms-powerpoint.presentation.macroEnabled.12"
        "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        "application/vnd.openxmlformats-officedocument.presentationml.slideshow"
        "application/vnd.oasis.opendocument.presentation"
      ]
      # Images — gwenview
      // openWith "org.kde.gwenview.desktop" [
        "image/jpeg"
        "image/png"
        "image/gif"
        "image/webp"
        "image/x-webp"
        "image/svg+xml"
        "image/bmp"
        "image/tiff"
        "image/avif"
        "image/heif"
      ]
      # Ebooks — calibre viewer
      // openWith "calibre-ebook-viewer.desktop" [
        "application/epub+zip"
        "application/x-kobo-epub+zip"
        "application/x-mobipocket-ebook"
        "application/x-mobipocket-subscription"
        "application/x-mobi8-ebook"
        "application/x-sony-bbeb"
        "application/ereader"
        "application/oebps-package+xml"
        "application/x-cb7"
        "application/x-cbc"
        "application/x-cbr"
        "application/x-cbz"
        "image/vnd.djvu"
        "text/fb2+xml"
      ];
    };
  };
}
