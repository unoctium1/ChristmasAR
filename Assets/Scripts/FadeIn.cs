using UnityEngine;
using System.Collections;
using TMPro;

public class FadeIn : MonoBehaviour
{
    TextMeshProUGUI text;
    Color col;
    [SerializeField] float duration;

    void Start()
    {
        text = GetComponent<TextMeshProUGUI>();
        col = text.color;
        col.a = 0f;
        text.color = col;
    }

    public void Fade()
    {
        StartCoroutine(FadeText());
    }

    private IEnumerator FadeText()
    {
        while (col.a < 0.95f)
        {
            col.a += Time.deltaTime / duration;
            text.color = col;
            yield return null;
        }
        col.a = 1f;
        text.color = col;
    }
}
