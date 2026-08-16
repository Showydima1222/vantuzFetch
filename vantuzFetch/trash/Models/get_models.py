#
#  get_models.py
#  vantuzFetch
#
#  Created by showydima on 13.08.2026.
#

import os
import re


folder_path = "." # Путь к вашей папке с html
result_dict = {}

for filename in os.listdir(folder_path):
    if filename.endswith(".html"):
        with open(os.path.join(folder_path, filename), "r", encoding="utf-8") as f:
            content = f.read()
            # ЭТО ГОВНО ПОТОМУ ЧТО ПО МОДЕЛИ ЭТОЙ ССАНОЙ ДУБЛИКАТЫ У ЭПЛ, ВОТ МРАЗИ. КОРОЧЕ БУДУ ПО BOARD ОПРЕДЕЛЯТЬ
            name_match = re.findall(r'<h2.*?>(.*?)<\/h2>', content) # ЭТО ОК ПОТОМУ ЧТО ЭТО ММЯ
            model_match = re.findall(r"Part Numbers?:\s?<\/b>\w?\s*([A-Za-z0-9, /]+)", content)

            if '<b>Find the name of your Mac model</b>' in name_match: name_match.pop(0)
            if 'Apple Footer' in name_match: name_match.pop(-1)
            if 'Learn more' in name_match: name_match.pop(-1)

            # apple moment 
            DOENST_PROVIDED = [
                # '<b>Mac Pro (Rack, 2019)</b>','Mac Pro (2019)', '<b>Mac Pro (Rack, 2023)</b>', 'Mac Pro (2023)' — i deleted mac pro files
                '<b>MacBook Pro (Retina, 15-inch, Mid 2012)</b>', ]
            for mac in DOENST_PROVIDED:
                if mac in name_match: name_match.pop(name_match.index(mac))
            

            # print(name_match, model_match)
            # print(len(name_match), len(model_match))
            for i in range(len(name_match)):
                buffer = model_match[i].lower().split(",")
                buffer = [i.strip() for i in buffer]
                buffer = [i.replace("xx/a", "") for i in buffer]
                buffer = [i.replace("xx/b", "") for i in buffer]
                for k in buffer:
                    if not k == "": print(f"\"{k}\": \"{name_match[i]}\",")

                



#            for i in range(len(name_match)):
#                buffer = model_match[i].lower().split(", ")
#                for k in buffer:
#                    name = name_match[i]
#                    name = name.replace("<b>", "")
#                    name = name.replace("</b>", "")
#                    print(f"\"{k}\": \"{name}\",")
#                # result_dict.update({model_match[i]: name_match[i]})
#                # "mac16,10": "Mac Mini (2024, M4)",

# print(result_dict)
