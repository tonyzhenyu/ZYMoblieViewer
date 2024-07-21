using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using ZY.MVVM;

public class PCDatas
{
    public string name;
    public string id;
    public string macAddress;
    public string ipAddress;
    public string port;
}

public class ListGroupView : ViewBase<ListGroupViewModel>
{
    public Text viewNameTitle;
    public Button addButton;
    
    public ListGroupItemWidget source;
    public RectTransform itemToPut;

    private List<ListGroupItemWidget> listItems;

    protected override void Init()
    {
        listItems = new List<ListGroupItemWidget>();

        addButton.onClick.AddListener(() =>
        {
            var newObject = GameObject.Instantiate(source.gameObject);
            listItems.Add(newObject.GetComponent<ListGroupItemWidget>());
            newObject.transform.SetParent(itemToPut.transform, false);
        });
    }
}
