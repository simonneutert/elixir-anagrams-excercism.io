defmodule Anagram do

  def match(word, word_list) do
    # keep words with same letter count and remove duplicates
    clean_word_list = filter_by_letter_count_and_duplicates(word, word_list)

    # build lists from filter masks
    apply_length = Enum.zip(clean_word_list, mask_length(word, clean_word_list))
    apply_case_count = Enum.zip(clean_word_list, mask_upcase_count(clean_word_list))
    apply_case = Enum.zip(clean_word_list, mask_case_insensitve_equality(word, clean_word_list))

    prepare_data(apply_length, apply_case_count, apply_case)
    |> build_key_value_pairs()
    |> Enum.zip()
    |> apply_rule_set()
  end

  defp sort_string(x) do
    Enum.sort(String.to_charlist(x))
  end

  defp mask_length(word, clean_word_list) do
    Enum.map(clean_word_list, (fn(x) -> sort_string(x) == sort_string(word) end))
  end

  defp mask_case_insensitve_equality(word, clean_word_list) do
    Enum.map(clean_word_list, fn(x) -> sort_string(String.downcase(word)) == sort_string(String.downcase(x)) end)
  end

  defp mask_upcase_count(clean_word_list) do
    Enum.map(clean_word_list, fn(x) -> Enum.count(String.codepoints(x), fn(y) -> y == String.upcase(y) end) <= 1 end)
  end

  defp filter_by_letter_count_and_duplicates(word, word_list) do
    Enum.filter(word_list, (fn(x) -> String.length(word) == String.length(x) end))
    |> Enum.filter(fn(x) -> String.upcase(x) != String.upcase(word)  end)
  end

  defp prepare_data(apply_length, apply_case_count, apply_case) do
    results_list = List.flatten([apply_length, apply_case_count, apply_case])
    results = Enum.map(results_list, fn({x,_}) -> x end) |> Enum.uniq()
    # return example:
    #
    # [[{"google", false}, {"google", true}, {"google", false}],
    #  [{"inlets", true}, {"inlets", true}, {"inlets", true}],
    #  [{"banana", false}, {"banana", true}, {"banana", false}]]
    Enum.map(results, fn(x) -> Enum.filter(results_list, fn({d,_}) -> x==d end) end)
  end

  defp build_key_value_pairs(clean_list) do
    keys =
      Enum.map(clean_list, fn(line) -> Enum.map(line, fn({a,_}) -> a end) end)
      |> Enum.map(fn(x) -> Enum.uniq(x) end)
    values = Enum.map(clean_list, fn(line) -> Enum.map(line, fn({_,b}) -> b end) end)
    [keys, values]
  end

  defp apply_rule_set(key_value) do
    # 1 keep words with same count and letters
    rule1 = Enum.filter(key_value, fn({_,y}) -> Enum.at(y, 0) == true end)
    # 2 keep words that aren't duplicates and may be uppercased
    rule2 =
      Enum.filter(key_value, fn({_,y}) -> Enum.at(y, 1) == true end)
      |> Enum.filter(fn({_,y}) -> Enum.at(y, 2) == true end)

    # chain results after filtering by rules
    ruleset = rule1 ++ rule2
    Enum.map(ruleset, fn({x,_}) -> List.first(x) end) |> Enum.uniq()
  end

end
