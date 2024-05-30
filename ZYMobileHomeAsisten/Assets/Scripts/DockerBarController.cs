using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using static UnityEditor.PlayerSettings;
public class DockerBarController :MonoBehaviour,IBeginDragHandler, IDragHandler,IEndDragHandler
{
    public RectTransform dockerPanel;
    public Image dockerBackground;
    Vector3 uiScreenPosition;
    Vector3 mouseScreenPosition;
    Vector3 mScreenPosition;
    private Vector3 offset;


    Camera mCamera;

    // Start is called before the first frame update
    void Start()
    {

        mCamera = Camera.main;
    }

    void Docking()
    {
        dockerPanel.position = Vector3.zero;
        dockerPanel.sizeDelta = Vector3.zero;
        dockerPanel.anchorMin = Vector2.zero;
        dockerPanel.anchorMax = Vector2.one;
        dockerPanel.anchoredPosition = Vector2.zero;
        dockerBackground.pixelsPerUnitMultiplier = 100;
    }
    public void OnBeginDrag(PointerEventData eventData)
    {

        //转换对象到当前屏幕位置
        uiScreenPosition = mCamera.WorldToScreenPoint(transform.position);
        mouseScreenPosition = mCamera.WorldToScreenPoint(eventData.position);

        //鼠标屏幕坐标
        mScreenPosition = new Vector3(mouseScreenPosition.x, mouseScreenPosition.y, uiScreenPosition.z);
        //获得鼠标和对象之间的偏移量,拖拽时相机应该保持不动
        offset = transform.position - mCamera.ScreenToWorldPoint(mScreenPosition);



    }

    public void OnDrag(PointerEventData eventData)
    {

        mouseScreenPosition = mCamera.WorldToScreenPoint(eventData.position);

        //鼠标屏幕上新位置
        mScreenPosition = new Vector3(mouseScreenPosition.x, mouseScreenPosition.y, uiScreenPosition.z);

        // 对象新坐标
        dockerPanel.position = offset + mCamera.ScreenToWorldPoint(mScreenPosition);



    }

    public void OnEndDrag(PointerEventData eventData)
    {

        if (eventData.position.x < Screen.width && eventData.position.x > 0 &&
            eventData.position.y < Screen.height && eventData.position.y > 0)
        {

        }
        else
        {
            Docking();
        }
    }

}
