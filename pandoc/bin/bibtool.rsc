%------------------------------------------------------------------------------------
% Custom bibtool settings to remove BibDesk fields and produce a clean bibliography
%------------------------------------------------------------------------------------

% Keep cite keys the same
preserve.keys = On
preserve.key.case = On

% Include cross references
select.crossrefs = On

% New entries to work with biblatex
% (bibtool complains about nonstandard entries)
new.entry.type = {online}
new.entry.type = {presentation}
new.entry.type = {report}

% Clean up fields for distribution
delete.field{rating}
delete.field{read}
delete.field{date-added}
delete.field{date-modified}
delete.field{keywords}

% It would be great if there was a wildcard-based solution for this...
delete.field{bdsk-file-1}
delete.field{bdsk-file-2}
delete.field{bdsk-file-3}
delete.field{bdsk-file-4}
delete.field{bdsk-file-5}
delete.field{bdsk-file-6}
delete.field{bdsk-file-7}
delete.field{bdsk-file-8}
delete.field{bdsk-file-9}
delete.field{bdsk-file-10}
delete.field{bdsk-file-11}
delete.field{bdsk-file-12}
delete.field{bdsk-file-13}
delete.field{bdsk-file-14}
delete.field{bdsk-file-15}
delete.field{bdsk-file-16}
delete.field{bdsk-file-17}
delete.field{bdsk-file-18}
delete.field{bdsk-file-19}
delete.field{bdsk-file-20}
delete.field{bdsk-url-1}
delete.field{bdsk-url-2}
delete.field{bdsk-url-3}
delete.field{bdsk-url-4}
delete.field{bdsk-url-5}
delete.field{bdsk-url-6}
delete.field{bdsk-url-7}
delete.field{bdsk-url-8}
delete.field{bdsk-url-9}
delete.field{bdsk-url-10}
delete.field{bdsk-url-11}
delete.field{bdsk-url-12}
delete.field{bdsk-url-13}
delete.field{bdsk-url-14}
delete.field{bdsk-url-15}
delete.field{bdsk-url-16}
delete.field{bdsk-url-17}
delete.field{bdsk-url-18}
delete.field{bdsk-url-19}
delete.field{bdsk-url-20}
