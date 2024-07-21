
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using ZY.Game;
using ZY.MVVM;


public class ListGroupView : ViewBase<ListGroupViewModel> 
{
    public Text viewNameTitle;
    public Button addButton;

    [Serializable]
    public struct Setting
    {
        public ListGroupItemWidget source;
        public RectTransform itemToPut;
        public int itemCount;
    }
    public Setting setting;
    private List<ListGroupItemWidget> listItems;

    protected override void Init()
    {
        
        listItems = new List<ListGroupItemWidget>(setting.itemCount);

        //for (int i = 0; i < listItems.Count; i++)
        //{
        //    var newObject = GameObject.Instantiate(setting.source.gameObject);
        //    newObject.transform.SetParent(setting.itemToPut.transform, false);
        //    newObject.SetActive(false);
        //    listItems.Add(newObject.GetComponent<ListGroupItemWidget>());
        //}

        addButton.onClick.AddListener(() =>
        {
            var newObject = GameObject.Instantiate(setting.source.gameObject);
            newObject.transform.SetParent(setting.itemToPut.transform, false);
            var widget = newObject.GetComponent<ListGroupItemWidget>();
            widget.button.onClick.AddListener(() =>
            {
                UIManager.GetInstance().ViewDictionary["View_EditItem"].GetObject().SetActive(true);
            });
            listItems.Add(widget);
        });
    }

}
