#pragma once
#include "events/EventScript.hpp"
#include <vector>
#include <cstdint>

namespace wxl::scripts::questmarker
{
    struct QuestSettings
    {
        bool    enabled      = true;
        bool    showMarker   = true;
        uint8_t alpha        = 165;
    };

    struct MarkerData
    {
        uint32_t questId  = 0;
        bool     active   = false;
        float    x = 0, y = 0, z = 0;
    };

    class QuestMarker final : public wxl::events::EventScript
    {
    public:
        QuestMarker();
        ~QuestMarker();

        static int ScriptSetMarker(void* state);
        static int ScriptClearAll(void* state);
        static int ScriptGetDistInfo(void* state);
        static int ScriptSetAlpha(void* state);
        static int ScriptReloadSettings(void* state);
        static int ScriptSetCorpseMarker(void* state);
        static int ScriptClearCorpseMarker(void* state);
        static int ScriptIsCorpseActive(void* state);
        static int ScriptGetCorpseDistInfo(void* state);
        static int ScriptSetDeadState(void* state);
        static int ScriptGetPlayerPos(void* state);
        static int ScriptSetTrackerDiamond(void* state);

        void SetMarker(uint32_t questId, bool active, float x, float y, float z);
        void ClearAllMarkers();
        void SetCorpseMarker(float x, float y, float z);
        void ClearCorpseMarker();

    private:
        void OnWorldRenderEnd(const wxl::events::WorldRenderEndArgs& a);
        void OnWorldLeave(const wxl::events::WorldLeaveArgs& a);
        void OnWorldEnter(const wxl::events::WorldEnterArgs& a);
        void OnDeviceLost(const wxl::events::DeviceResetArgs& a);
        void OnDeviceReset(const wxl::events::DeviceResetArgs& a);

        void InitDevice(void* device);
        void ReleaseDevice();

        std::vector<MarkerData> m_markers;
        float    m_ndcX = 0, m_ndcY = 0;
        float    m_dist = 0;
        bool     m_markerValid = false;
        bool     m_corpseActive = false;
        float    m_corpseX = 0, m_corpseY = 0, m_corpseZ = 0;
        float    m_corpseNdcX = 0, m_corpseNdcY = 0;
        float    m_corpseDist = 0;
        bool     m_corpseNdcValid = false;
        bool     m_deadState = false;
        bool     m_trackerDiamondActive = false;
        float    m_trackerNdcX = 0, m_trackerNdcY = 0;
        float    m_trackerNdcHalfW = 0, m_trackerNdcHalfH = 0;
        bool     m_deviceReady = false;
        void*    m_d3dTexture = nullptr;
        void*    m_vb = nullptr;
        int      m_vbSize = 0;
        uint32_t m_alpha = 165;
        int m_worldEnterFrameCount = 0;
        QuestSettings m_settings;
    };
}
