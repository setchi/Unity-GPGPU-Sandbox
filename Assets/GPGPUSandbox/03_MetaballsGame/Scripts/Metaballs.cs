using System.Linq;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Rendering;
using UnityEngine.UI;

namespace UnityGpuSandbox.MetaballsGame
{
    public partial class Metaballs : MonoBehaviour
    {
        [SerializeField]
        Material material;
        [SerializeField]
        CanvasScaler canvasScaler;
        [SerializeField]
        Transform playerLabel;

        void Update()
        {
            var mousePosition = Input.mousePosition;

            var uv = new Vector3(
                mousePosition.x / Screen.width,
                mousePosition.y / Screen.height, 0);

            material.SetVector("_PlayerPosition", uv);

            playerLabel.position = new Vector2(
                uv.x * canvasScaler.referenceResolution.x * canvasScaler.transform.localScale.x,
                uv.y * canvasScaler.referenceResolution.y * canvasScaler.transform.localScale.y
            );
        }
    }
}