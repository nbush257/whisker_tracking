# want the naming convention to be:
# motor_[trial_type]_[direction]_[whisker]_[trial_modifier]_[trial_index]_[view]
# trial modifier indicates different peg positions or speed choices.

import os
import re
main_dir = r'D:\motor_experiment\video_data'
good_dir = os.path.join(main_dir,'_good')
bad_dir = os.path.join(main_dir,'_bad')
unfinished_dir = os.path.join(main_dir,'_unfinished')


for root,dirs,files in os.walk(good_dir):
    for file in files:
        whisker = re.search('[A-Z]{1,2}\d',file).group().upper()

        # get trial type
        trial_type = re.search('(?i)collision|(?i)sinewave|(?i)ping',file).group().lower()

        # get direction if it exists
        if trial_type == 'ping' or 'collision':
            direction = re.search('(?i)neg|(?i)pos',file).group().lower()
            # get modifier
            token = '(?<={}).*(?={})'.format(direction, whisker)
            modifier = re.search(token, file).group().strip('_')

        else:
            direction = 'X'

        # shorten trial type to 4 chars
        if trial_type == 'collision':
            trial_type = 'coll'
        elif trial_type == 'sinewave':
            trial_type = 'sine'


        # map direction to one letter
        if direction == 'neg':
            direction = 'N'
        elif direction == 'pos':
            direction = 'P'
        else:
            direction = 'X'
        # if there is no array side, mark it as X
        if len(whisker) < 3:
            whisker = 'R' + whisker
        # get trial index
        trial_idx = re.search('t\d{2}',file).group().lower()

        view = re.search('(?i)front|(?i)top',file).group().lower()

        newname= '_'.join(['motor',trial_type,direction,whisker,'e'+modifier.zfill(2),trial_idx,view])
        print file
        print newname
        print '\n'


