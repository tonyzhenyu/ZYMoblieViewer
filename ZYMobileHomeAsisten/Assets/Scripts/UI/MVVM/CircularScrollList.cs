using UnityEngine;
using UnityEngine.UI;

public class CircularScrollList : MonoBehaviour
{
    public GameObject itemPrefab;
    public int totalItemCount;
    public int visibleItemCount;

    private RectTransform contentRect;
    private RectTransform[] items;
    private float itemHeight;

    private void Start()
    {
        contentRect = GetComponent<ScrollRect>().content;
        itemHeight = itemPrefab.GetComponent<RectTransform>().rect.height;
        items = new RectTransform[visibleItemCount];

        for (int i = 0; i < visibleItemCount; i++)
        {
            GameObject newItem = Instantiate(itemPrefab, contentRect);
            newItem.transform.localPosition = new Vector2(0, -itemHeight * i);
            items[i] = newItem.GetComponent<RectTransform>();
            UpdateItem(i, i);
        }

        contentRect.sizeDelta = new Vector2(contentRect.sizeDelta.x, itemHeight * totalItemCount);
    }

    private void Update()
    {
        for (int i = 0; i < visibleItemCount; i++)
        {
            if (items[i].localPosition.y + contentRect.anchoredPosition.y < -itemHeight / 2)
            {
                float newY = items[i].localPosition.y + itemHeight * visibleItemCount;
                items[i].localPosition = new Vector2(0, newY);
                int newIndex = (int)(newY / itemHeight) % totalItemCount;
                UpdateItem(i, newIndex);
            }
            else if (items[i].localPosition.y + contentRect.anchoredPosition.y > itemHeight * visibleItemCount - itemHeight / 2)
            {
                float newY = items[i].localPosition.y - itemHeight * visibleItemCount;
                items[i].localPosition = new Vector2(0, newY);
                int newIndex = (int)(newY / itemHeight) % totalItemCount;
                UpdateItem(i, newIndex);
            }
        }
    }

    private void UpdateItem(int itemIndex, int dataIndex)
    {
        Text itemText = items[itemIndex].GetComponentInChildren<Text>();
        itemText.text = "Item " + dataIndex;
    }
}
