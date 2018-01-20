defmodule Anagram do
  def match(word, word_list) do
    # public API
    filter_by_letter_count_and_duplicates(word, word_list)
    |> build_bool_masks(word)
    |> apply_bool_masks()
    |> build_key_value_pairs()
    |> apply_rule_set()
    |> map_results()
  end

  defp sort_string(x) do
    Enum.sort(String.to_charlist(x))
  end

  defp filter_by_letter_count_and_duplicates(word, word_list) do
    Enum.filter(word_list, fn x -> String.length(word) == String.length(x) end)
    |> Enum.filter(fn x -> String.upcase(x) != String.upcase(word) end)
  end

  defp build_bool_masks(clean_word_list, word) do
    []
    |> Enum.concat(mask_length(word, clean_word_list))
    |> Enum.concat(mask_upcase_count(clean_word_list))
    |> Enum.concat(mask_case_insensitve_equality(word, clean_word_list))
    |> List.flatten()
  end

  defp apply_bool_masks(bool_masks) do
    Enum.map(bool_masks, fn {x, _} -> x end)
    |> Enum.uniq()
    |> Enum.map(fn x -> Enum.filter(bool_masks, fn {d, _} -> x == d end) end)
  end

  defp mask_length(word, clean_word_list) do
    bool_mask = Enum.map(clean_word_list, fn x -> sort_string(x) == sort_string(word) end)
    Enum.zip(clean_word_list, bool_mask)
  end

  defp mask_case_insensitve_equality(word, clean_word_list) do
    bool_mask =
      Enum.map(clean_word_list, fn x ->
        sort_string(String.downcase(word)) == sort_string(String.downcase(x))
      end)

    Enum.zip(clean_word_list, bool_mask)
  end

  defp mask_upcase_count(clean_word_list) do
    bool_mask =
      Enum.map(clean_word_list, fn x ->
        Enum.count(String.codepoints(x), fn y -> y == String.upcase(y) end) <= 1
      end)

    Enum.zip(clean_word_list, bool_mask)
  end

  defp build_key_value_pairs(clean_list) do
    keys =
      Enum.map(clean_list, fn line -> Enum.map(line, fn {a, _} -> a end) end)
      |> Enum.map(fn x -> Enum.uniq(x) end)

    values = Enum.map(clean_list, fn line -> Enum.map(line, fn {_, b} -> b end) end)

    Enum.zip(keys, values)
  end

  defp apply_rule_set(key_value) do
    []
    |> Enum.concat(rule_keep_same_letters_length(key_value))
    |> Enum.concat(rule_drop_dups_check_case(key_value))
  end

  defp rule_keep_same_letters_length(key_value) do
    Enum.filter(key_value, fn {_, y} -> Enum.at(y, 0) == true end)
  end

  defp rule_drop_dups_check_case(key_value) do
    Enum.filter(key_value, fn {_, y} -> Enum.at(y, 1) == true end)
    |> Enum.filter(fn {_, y} -> Enum.at(y, 2) == true end)
  end

  defp map_results(hitlist) do
    Enum.map(hitlist, fn {x, _} -> List.first(x) end)
    |> Enum.uniq()
  end
end
