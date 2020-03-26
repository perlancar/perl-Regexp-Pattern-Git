package Regexp::Pattern::Git;

# DATE
# VERSION

our %RE = (
    ref => {
        summary => 'Valid reference name',
        description => <<'_',

This single regex pattern enforces the rules defined by the git-check-ref-format
manpage, reproduced below:

1. They can include slash / for hierarchical (directory) grouping, but no
   slash-separated component can begin with a dot . or end with the sequence
   .lock.

2. They must contain at least one /. This enforces the presence of a category
   like heads/, tags/ etc. but the actual names are not restricted.

3. They cannot have two consecutive dots .. anywhere.

4. They cannot have ASCII control characters (i.e. bytes whose values are lower
   than \040, or \177 DEL), space, tilde ~, caret ^, or colon : anywhere.

5. They cannot have question-mark ?, asterisk *, or open bracket [ anywhere.

6. They cannot begin or end with a slash / or contain multiple consecutive
   slashes.

7. They cannot end with a dot ..

8. They cannot contain a sequence: @ followed by {.

9. They cannot be the single character @.

10. They cannot contain a \.

_
        pat => qr(
                     \A(?:

                         # 1. (a) no slash-separated component can begin with a dot
                         (?!\.)
                         (?![^/]+/\.)

                         # 1. (b) ... or end with ".lock"
                         (?![^.]*\.lock(?:\z|/))

                         # 2. must contain at least one /
                         (?=[^/]*/)

                         # 3. cannot contain two consecutive dots anywhere
                         (?![^.]*\.\.)

                         # 4. cannot contain control char (<\040), DEL (\0177), space, tilde, caret, or colon anywhere
                         (?![^\000-\037\177 ~^:]*[\000-\037\177 ~^:])

                         # 5. cannot have question-mark ?, asterisk *, or open bracket [ anywhere
                         (?![^?*\[]*[?*\[])

                         # 6. (a) cannot begin with a slash, or contain multiple slashes
                         (?!/)
                         (?![^/]*//)

                         # 8. cannot contain the sequence: @ followed by {
                         (?![^@]*@\{)

                         # 9. cannot be single character @, implied by rule #2

                         # 10. cannot contain backslash
                         (?![^\\]*\\)

                         .+

                         # 6. (b) cannot end with a slash
                         (?<!/)

                         # 7. cannot end with a dot
                         (?<!\.)
                     )\z
                 )x,
        tags => ['anchored'],
        examples => [
            {str=>'foo/bar', matches=>1},

            {str=>'.foo/bar', matches=>0, summary=>'A slash-separated component begins with dot (rule 1)'},
            {str=>'foo/.bar', matches=>0, summary=>'A slash-separated component begins with dot (rule 1)'},

            {str=>'foo.lock/bar', matches=>0, summary=>'A slash-separated component ends with ".lock" (rule 1)'},
            {str=>'foo.locker/bar', matches=>1},
            {str=>'foo/bar.lock', matches=>0, summary=>'A slash-separated component ends with ".lock" (rule 1)'},
            {str=>'foo/bar.lock/baz', matches=>0, summary=>'A slash-separated component ends with ".lock" (rule 1)'},
            {str=>'foo/bar.locker/baz', matches=>1},

            {str=>'foo', matches=>0, summary=>'Does not contain at least one / (rule 2)'},

            {str=>'foo../bar', matches=>0, summary=>'Contains two consecutive dots (rule 3)'},

            {str=>'foo:/bar', matches=>0, summary=>'Contains colon (rule 4)'},

            {str=>'foo?/bar', matches=>0, summary=>'Contains question mark (rule 5)'},
            {str=>'foo[2]/bar', matches=>0, summary=>'Contains open bracket (rule 5)'},

            {str=>'/foo/bar', matches=>0, summary=>'Begins with / (rule 6)'},
            {str=>'foo/bar/', matches=>0, summary=>'Ends with / (rule 6)'},
            {str=>'foo//bar', matches=>0, summary=>'Contains multiple consecutive slashes'},

            {str=>'foo/bar.', matches=>0, summary=>'Ends with . (rule 7)'},

            {str=>'foo@{/bar', matches=>0, summary=>'Contains sequence @{ (rule 8)'},
            {str=>'foo@{baz}/bar', matches=>0, summary=>'Contains sequence @{ (rule 8)'},

            {str=>'@', matches=>0, summary=>'Cannot be single character @ (rule 9)'},
        ],
    },

    release_tag => {
        summary => 'Common release tag pattern',
        pat => qr/(?:(?:version|ver|v|release|rel)[_-]?)?\d/,
        description => <<'_',

This is not defined by git, but just common convention.

_
        tags => ['convention'],
        examples => [
            {str=>'release', matches=>0, summary=>'Does not contain digit'},
            {str=>'1', matches=>1},
            {str=>'1.23-456-foobar', matches=>1},
            {str=>'release-1.23', matches=>1},
            {str=>'v1.23', matches=>1},
            {str=>'ver-1.23', matches=>1},
        ],
    },
);

1;
# ABSTRACT: Regexp patterns related to git
