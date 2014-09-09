CAH Builder
===========
This project helps you to create full size (63x88mm) custom generated [Cards Against Humanity](http://cardsagainsthumanity.com/) cards from plain text.
The resulting images ~~will~~ should work at [Make Playing Cards](http://www.makeplayingcards.com/). 63 x 88mm, 310 GSM linen finish cards are recommended.

Project Status
--------------
This project is still a work in progress. The following issues are yet to be addressed:

* The card images have not yet been tested at [Make Playing Cards](http://www.makeplayingcards.com/).
* The 'back' image is not yet included.
* The generated images may not match the cards in the Base game in all cases (need changes to whitespace length determination, forced newlines)

Requirements
------------
You will need the following softwares to run CAH Builder:

* make
* gawk
* inkscape
* xmlstarlet
* 'Nimbus Sans L Bold' font (very close to the Helvetica font used on the actual cards)

On Ubuntu just run:
```
sudo apt-get install make gawk xmlstarlet inkscape
```

Usage
-----
Edit the [media/list](media/list) file with your favorite text editor. 

The format of the file is one line per card. Lines will normally wrap automatically, but you can force a newline using `\n`.
A single underscore character `_` will be extended to the end of the line in most cases (See [Underscore Rules](#underscore-rules)).
Apostrophes and quotes will automatically be turned into curly versions: `'` will turn into `’` and `"foo"` will turn into `“foo”`.

Don't worry about white vs. black cards, or if it is a Pick 2 or a Pick 3, etc. All of that is automagically determined (See [Grammar Rules](#grammar-rules)).

When you are satisfied with your list, run:
```
make
```

1200 DPI PNG images will be created under out_png. The SVG files will be available under out_svg.
The preprocessed list is available as pre_list. A wrapped text preview is available as wrap_list.

Underscore Rules
----------------
Subject to change. The current rules do not exactly match those used for actual cards. They mostly do.

A single under score surrounded by whitespace ` _ ` will attempt to extend toward the end of the line. If it is not long enough, at least 10 underscores `__________`, then it will take up the entirety of the next line.

If the underscore is part of a word, such as `_-tastic!` or includes punctuation: `_.` the whole token will be extended. If there are not enough underscores the word will take up the entirety of the next line.

You can specify any underscore length you want (besides 1) by using multiple underscores.

Grammar Rules
-------------
As far as CAH Builder is concerned, if it is not a black card, it is a white one. But you may want to look at the [list](media/list) and follow the general pattern.
The white cards are most often physical things or abstract ideas, not commands or questions. They are often prepended as `A foo` or `The foo` and usually end in a period. 
Every guideline I just mentioned has an exception however, most notably `Bees?` and `YOU MUST CONSTRUCT ADDITIONAL PYLONS.`

The black cards are determined in three separate ways. One, if the text is a question. Questions contain at least one [interrogative word](http://www.hopstudios.com/nep/unvarnished/item/list_of_english_question_words) and end with a `?`. Two, if it contains one or more blanks, which are each one or more consecutive underscores. The number of blanks determines Standard vs. Pick 2 vs Pick 3. Three, if it contains the word `haiku`, it's a black Pick 3 card and that's that.

Licensing
---------
The files under [media](media/) are derived from [Cards Against Humanity LLC](http://cardsagainsthumanity.com/) material and are covered under the [CC BY-NC-SA 2.0](http://creativecommons.org/licenses/by-nc-sa/2.0/) license.

Everything else is covered under [GPLv3 (or any later version)](http://www.gnu.org/licenses/gpl.html).

Details in [License](LICENSE.md).
